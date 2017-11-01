# DEFINE OPTIONS

set val(chan)	Channel/WirelessChannel		;# channel type
set val(prop)	Propagation/TwoRayGround	;# radio-propogation model
set val(netif)	Phy/WirelessPhy			;# network interface type
set val(mac)	Mac/802_11			;# MAC type
set val(ifq)	Queue/DropTail/PriQueue	        ;# interface queue type
set val(ll)	LL				;# link layer type
set val(ant)	Antenna/OmniAntenna		;# antenna model
set val(ifqlen)	50				;# max packet in ifq
set val(nn)	50				;# number of mobilenodes
set val(rp)	AODV				;# routing protocol

set ns [new Simulator]

# trace file
$ns use-newtrace
set tracefd [open rtp_$val(nn).tr w]
$ns trace-all $tracefd

# namtrace file
set namtrace [open less.nam w]
$ns namtrace-all-wireless $namtrace 1000 1000

set topo [new Topography]
$topo load_flatgrid 1000 1000

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
	$node($i) random-motion 0
}

# set random x and y for nodes
for {set i 1} {$i <= $val(nn)} {incr i} {
	$node($i) set X_ [expr int(rand()*1000)]
	$node($i) set Y_ [expr int(rand()*1000)]
	$node($i) set Z_ 0.0
}

# set random destination of nodes for movement
for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns at [expr ($i+1)*5] "$node($i) setdest [expr int(rand()*1000)] [expr int(rand()*1000)] [expr int(rand()*20)]"
}

# define udp agents
set tcp [new Agent/RTP]
set sink [new Agent/RTP]

# attach udp agents to network
$ns attach-agent $node(1) $tcp
$ns attach-agent $node($val(nn)) $sink

# connect source and sink
$ns connect $tcp $sink

# define cbr application for udp
set ftp [new Application/FTP]

# attach application to agent
$ftp attach-agent $tcp

$ns at 1.0 "$ftp start"

for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns at 500.0 "$node($i) reset";
}

$ns at 500.0 "stop"

proc stop {} {
	global ns tracefd
	$ns flush-trace
	exec nam less.nam
	close $tracefd
}

$ns run
