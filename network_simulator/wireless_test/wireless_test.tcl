# DEFINE OPTIONS

set val(chan)	Channel/WirelessChannel		;# channel type
set val(prop)	Propagation/TwoRayGround	;# radio-propogation model
set val(netif)	Phy/WirelessPhy			;# network interface type
set val(mac)	Mac/802_11			;# MAC type
set val(ifq)	Queue/DropTail/PriQueue		;# interface queue type
set val(ll)	LL				;# link layer type
set val(ant)	Antenna/OmniAntenna		;# antenna model
set val(ifqlen)	50				;# max packet in ifq
set val(nn)	5				;# number of mobilenodes
set val(rp)	DSDV				;# routing protocol

set ns [new Simulator]

$ns use-newtrace
set tracefd [open simple.tr w]

$ns trace-all $tracefd

set namtrace [open less.nam w]
$ns namtrace-all-wireless $namtrace 500 500

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
	set node($i) [$ns node]
	$node($i) random-motion 0;
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$node($i) set X_ [expr int(rand()*300)]
	$node($i) set Y_ [expr int(rand()*300)]
	$node($i) set Z_ 0.0
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at [expr ($i+1)*5] "$node($i) setdest [expr int(rand()*300)] [expr int(rand()*300)] [expr int(rand()*20)]"
}

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp
$ns attach-agent $node(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at 30.0 "$node($i) reset";
}

$ns at 30.0 "stop"

proc stop {} {
	global ns tracefd
	$ns flush-trace
	exec nam less.nam
	close $tracefd
}

$ns run
