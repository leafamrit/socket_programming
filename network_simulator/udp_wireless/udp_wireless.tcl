# DEFINE OPTIONS

set val(chan)	Channel/WirelessChannel		;# channel type
set val(prop)	Propagation/TwoRayGround	;# radio-propogation model
set val(netif)	Phy/WirelessPhy			;# network interface type
set val(mac)	Mac/802_11			;# MAC type
set val(ifq)	Queue/DropTail/PriQueue		;# interface queue type
set val(ll)	LL				;# link layer type
set val(ant)	Antenna/OmniAntenna		;# antenna model
set val(ifqlen)	50				;# max packet in ifq
set val(nn)	20				;# number of mobilenodes
set val(rp)	AODV				;# routing protocol

set ns [new Simulator]

# trace file
$ns use-newtrace
set tracefd [open simple.tr w]
$ns trace-all $tracefd

# namtrace file
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

# define nodes
for {set i 1} {$i <= $val(nn)} {incr i} {
	set node($i) [$ns node]
	$node($i) random-motion 0;
}

# set x and y for nodes
for {set i 1} {$i <= $val(nn)} {incr i} {
	$node($i) set X_ [expr int(rand()*300)]
	$node($i) set Y_ [expr int(rand()*300)]
	$node($i) set Z_ 0.0
}

# set destination of nodes for movement
for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns at [expr ($i+1)*5] "$node($i) setdest [expr int(rand()*300)] [expr int(rand()*300)] [expr int(rand()*20)]"
}

# define udp agents
set udp [new Agent/UDP]
set null [new Agent/Null]

# attach udp agents to network
$ns attach-agent $node(1) $udp
$ns attach-agent $node($val(nn)) $null

# connect source and sink
$ns connect $udp $null

# define cbr application for udp
set cbr [new Application/Traffic/CBR]

# attach application to agent
$cbr attach-agent $udp

# configure cbr application
$cbr set packetSize_ 512
$cbr set interval 0.1

$ns at 1.0 "$cbr start"

for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns at 300.0 "$node($i) reset";
}

$ns at 300.0 "stop"

proc stop {} {
	global ns tracefd
	$ns flush-trace
	exec nam less.nam
	close $tracefd
}

$ns run
