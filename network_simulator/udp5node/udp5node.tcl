# create a simulator
set ns [new Simulator]

# use dynamic routing
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

# create 8 nodes
for {set i 0} {$i < 5} {incr i} {
	set n($i) [$ns node]
}

# connect nodes
for {set i 0} {$i < 4} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)]) 1Mb 10ms DropTail
}

$ns duplex-link-op $n(0) $n(1) color blue

# create a udp agent and attach to n0 (traffic source)
set udp0 [new Agent/UDP]
$ns attach-agent $n(1) $udp0

# create CBR(Constant Bit Rate) traffic and attach to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# create null traffic sink at n(5)
set null0 [new Agent/Null]
$ns attach-agent $n(4) $null0

# connect udp0 to null0
$ns connect $udp0 $null0

# event scheduling
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

# call finish at 5 sec
$ns at 5.0 "finish"

# run the sim
$ns run
