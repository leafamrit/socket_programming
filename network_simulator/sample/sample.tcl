#http://nile.wpi.edu/NS/simple_ns.html

#1. Create instance of network simulator object
set ns [new Simulator]  
#generates an NS simulator object instance, and assigns it to variable ns

#2a. Turn on NAM (network animator)
set nm [open out.nam w] 
$ns namtrace-all $nm	
#This member function tells the simulator to record simulation traces in NAM input format. It also gives the file name that the trace will be written to later by the command $ns flush-trace. 

#2b. Turn on tracing (traffic and packet status)
set nt [open out.tr w]
$ns trace-all $nt

#3. Define "Finish" procedure and write instruction to open nam file
proc finish {} {
	global ns nm nt
	$ns flush-trace
	close $nm
	close $nt
	exec nam out.nam 
	exit 0
	}

#4i. #Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$n0 color red
$n1 shape hexagon
$n3 label "Host"
$n2 add-mark m1 blue box
$n2 delete-mark m1


$ns at 1.0 "$n0 label \"I am sending data\""
$ns at 3.0 "$ns trace-annotate \"packet sending\""
#. trace-annotate ? Comment given in the trace annotate is displayed at the bottom of the Network Animator window

#4iii. Create links between the nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms RED


#Give node position  < comment and check> (for NAM)
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient down
$ns duplex-link-op $n2 $n3 orient left

#4iv. Define colors for data flow <Comment and check> (for NAM)
$ns color 1 yellow
$ns color 2 blue

#4v.Set Queue Size of link (n2-n3) to 10 <vary parameter and check>
$ns queue-limit $n2 $n3 10

#4vi. Monitor the queue for link (n2-n3). <Comment and check> (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5

#4vii. Attach agents TCP/FTP or UDP/CBR
#Setup a TCP connection
set tcp [new Agent/TCP]
#$tcp set class_ 2
$ns attach-agent $n0 $tcp
# or $n0 attach $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

# connect source and sink
$ns connect $tcp $sink

#give id for flow <comment and check>
$tcp set fid_ 1


#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
#$ftp set type_ FTP


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp

set udpsink [new Agent/Null]
$ns attach-agent $n3 $udpsink

$ns connect $udp $udpsink
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
#$cbr set type_ CBR
#$cbr set packet_size_ 1000
#$cbr set rate_ 1mb
#$cbr set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

#Detach tcp and sink agents (not really necessary)
$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "Starting NAM simulation...."

#Run the simulation
$ns run

