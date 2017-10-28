# DEFINE OPTIONS

set val(chan)	Channel/WirelessChannel		;# channel type
set val(prop)	Propagation/TwoRayGround	;# radio-propogation model
set val(netif)	Phy/WirelessPhy			;# network interface type
set val(mac)	Mac/802_11			;# MAC type
set val(ifq)	Queue/DropTail/PriQueue		;# interface queue type
set val(ll)	LL				;# link layer type
set val(ant)	Antenna/OmniAntenna		;# antenna model
set val(ifqlen)	50				;# max packet in ifq
set val(nn)	4				;# number of mobilenodes
set val(rp)	AODV				;# routing protocol

set ns [new Simulator]

set ntrace [open ntrace.tr w]
$ns trace-all $ntrace

set nnam [open nnam.nam w]
$ns namtrace-all-wireless $nnam 500 500

set topo [new Topography]
$topo load_flatgrid 500 500

create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
		-llType	$val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channelType $val(chan) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF


for {set i 0} {$i < $val(nn)} {incr i} {
	set n($i) [$ns node]
	$n($i) random-motion 0
}

$n(0) label "TCP Source"
$n(0) color red
$n(0) shape square
$n(0) set X_ 10.0
$n(0) set Y_ 10.0
$n(0) set Z_ 0.0

$n(1) label "TCP Sink"
$n(1) color blue
$n(1) shape square
$n(1) set X_ 490.0
$n(1) set Y_ 490.0
$n(1) set Z_ 0.0

$n(2) label "UDP Source"
$n(2) color green
$n(2) shape hexagon
$n(2) set X_ 10.0
$n(2) set Y_ 490.0
$n(2) set Z_ 0.0

$n(3) label "UDP Sink"
$n(3) color yellow
$n(3) shape hexagon
$n(3) set X_ 490.0
$n(3) set Y_ 10.0
$n(3) set Z_ 0.0

$ns at 10.0 "$n(0) setdest 100.0 100.0 30.0"
$ns at 10.0 "$n(1) setdest 100.0 110.0 30.0"
$ns at 10.0 "$n(2) setdest 150.0 100.0 30.0"
$ns at 10.0 "$n(3) setdest 150.0 110.0 30.0"

set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n(1) $tcpsink

$ns connect $tcp $tcpsink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 10.0 "$ftp start"

set udp [new Agent/UDP]
$ns attach-agent $n(2) $udp

set udpsink [new Agent/Null]
$ns attach-agent $n(3) $udpsink

$ns connect $udp $udpsink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 500
$cbr set interval_ 0.005

$ns at 10.0 "$cbr start"

for {set i 0} {$i < 4} {incr i} {
	$ns at 300.0 "$n($i) reset";
}

$ns at 300.0 "stop"

proc stop {} {
	global ns nnam ntrace
	$ns flush-trace
	exec nam nnam.nam
	close $ntrace
	exit 0
}

$ns run
