set ns [new Simulator]

$ns rtproto DV

set ntrace [open ntrace.tr w]
$ns trace-all $ntrace

set namtrace [open namtrace.nam w]
$ns namtrace-all $namtrace

proc stop {} {
	global ns ntrace namtrace
	$ns flush-trace
	exec nam namtrace.nam
	close $ntrace
	exit 0
}

for {set i 0} {$i < 10} {incr i} {
	set n($i) [$ns node]
}

for {set i 0} {$i < 10} {incr i; incr i} {
	$n($i) color yellow
	$n($i) shape hexagon
}

for {set i 1} {$i < 10} {incr i; incr i} {
	$n($i) color green
}

for {set i 0} {$i < 10} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)%10]) 1Mb 10ms DropTail
}

$ns duplex-link-op $n(0) $n(1) orient right-down
$ns duplex-link-op $n(1) $n(2) orient down
$ns duplex-link-op $n(2) $n(3) orient left-down
$ns duplex-link-op $n(3) $n(4) orient down
$ns duplex-link-op $n(4) $n(5) orient right-down
$ns duplex-link-op $n(5) $n(6) orient right-up
$ns duplex-link-op $n(6) $n(7) orient up
$ns duplex-link-op $n(7) $n(8) orient left-up
$ns duplex-link-op $n(8) $n(9) orient up
$ns duplex-link-op $n(9) $n(0) orient right-up

set tcp [new Agent/TCP]
$ns attach-agent $n(9) $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n(8) $tcpsink

$ns connect $tcp $tcpsink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 5.0 "$ftp start"
$ns at 145.0 "$ftp stop"

$ns at 150.0 "stop"

$ns run

