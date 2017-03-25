set ns [new Simulator]

$ns rtproto DV

set nm [open out.nam w]
$ns namtrace-all $nm

set nt [open out.tr w]
$ns trace-all $nt

proc finish {} {
	global ns nm nt
	$ns flush-trace
	close $nm
	close $nt
	exec nam out.nam
	exit 0
}

for {set i 0} {$i < 6} {incr i} {
	set n($i) [$ns node]
}

for {set i 0} {$i < 5} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)]) 1Mb 10ms DropTail
}

set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n(5) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.5 "$ftp start"
$ns rtmodel-at 2.5 down $n(3) $n(4)
$ns rtmodel-at 2.7 down $n(4) $n(5)
$ns rtmodel-at 3.0 up $n(3) $n(4)
$ns rtmodel-at 3.5 up $n(4) $n(5)
$ns at 4.5 "$ftp stop"

$ns at 5.0 "finish"

$ns run
