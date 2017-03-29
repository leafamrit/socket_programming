BEGIN {
print("\n\n******** Network Statistics ********\n");

# Change array size from 50 to any number of nodes for which u are doing simulation. 
# i.e. change values of arrays packet_sent, packet_drop, packet_recvd, packet_forwarded, energy_left, 
packet_sent[50] = 0;
packet_drop[50] = 0;
packet_recvd[50] = 0;
packet_forwarded[50] = 0;

# Change energy assigned to initial node (as per your simulation tcl file)
# Initial Energy assigned to each node in Joules

energy_left[50] = 10000.000000;			

total_pkt_sent=0;
total_pkt_recvd=0;
total_pkt_drop=0;
total_pkt_forwarded=0;
pkt_delivery_ratio = 0;
total_hop_count = 0;
avg_hop_count = 0;
overhead = 0;
start = 0.000000000;
end = 0.000000000;
packet_duration = 0.0000000000;
recvnum = 0;
delay = 0.000000000;
sum = 0.000000000;
i=0;
total_energy_consumed = 0.000000;
}

{
state		= 	$1;
time 		= 	$3;

# For energy consumption statistics see trace file
node_num	= 	$5;
energy_level 	= 	$7;
	

node_id 	= 	$9;
level 		= 	$19;
pkt_type 	= 	$35;
packet_id	= 	$41;
no_of_forwards 	=	$49;

# In for loop change values from 50 to number of nodes that u specify for your simulation  

if((pkt_type == "cbr") && (state == "s") && (level=="AGT")) { 
	for(i=0;i<50;i++) {
		if(i == node_id) {
		packet_sent[i] = packet_sent[i] + 1; }
}
}else if((pkt_type == "cbr") && (state == "r") && (level=="AGT")) { 
	for(i=0;i<50;i++) {
		if(i == node_id) {
		packet_recvd[i] = packet_recvd[i] + 1; }
}
}else if((pkt_type == "cbr") && (state == "d")) { 
	for(i=0;i<50;i++) {
		if(i == node_id) {
		packet_drop[i] = packet_drop[i] + 1; }
}
}else if((pkt_type == "cbr") && (state == "f")) { 
	for(i=0;i<50;i++) {
		if(i == node_id) {
		packet_forwarded[i] = packet_forwarded[i] + 1; }
}
}

# To calculate total hop counts
if ((state == "r") && (level == "RTR") && (pkt_type == "cbr")) { total_hop_count = total_hop_count + no_of_forwards; }

# Routing Overhead
if ((state == "s" || state == "f") && (level == "RTR") && (pkt_type == "message")) { overhead = overhead + 1; }

# Calculating Average End to End Delay

#if ( start_time[packet_id] == 0 )  { start_time[packet_id] = time; }

if (( state == "s") &&  ( pkt_type == "cbr" ) && ( level == "AGT" ))  { start_time[packet_id] = time; }

 if (( state == "r") &&  ( pkt_type == "cbr" ) && ( level == "AGT" )) {  end_time[packet_id] = time;  }
 else {  end_time[packet_id] = -1;  }

# To Calculate Average Energy Consumption

# Change number of nodes in this for loop also

if(state == "N") {
	for(i=0;i<50;i++) {
		if(i == node_num) {
					energy_left[i] = energy_left[i] - (energy_left[i] - energy_level);
				}
			
			  }
}
 
}
# In this for loop also change 

END {
for(i=0;i<50;i++) {
printf("%d %d \n",i, packet_sent[i]) > "pktsent.txt";
printf("%d %d \n",i, packet_recvd[i]) > "pktrecvd.txt";
printf("%d %d \n",i, packet_drop[i]) > "pktdrop.txt";
printf("%d %d \n",i, packet_forwarded[i]) > "pktfwd.txt";
printf("%d %.6f \n",i, energy_left[i]) > "energyleft.txt";

total_pkt_sent = total_pkt_sent + packet_sent[i];
total_pkt_recvd = total_pkt_recvd + packet_recvd[i];
total_pkt_drop = total_pkt_drop + packet_drop[i];
total_pkt_forwarded = total_pkt_forwarded + packet_forwarded[i];
total_energy_consumed = total_energy_consumed + energy_left[i];

}
printf("Total Packets Sent 		:	%d\n",total_pkt_sent);
printf("Total Packets Received 		:	%d\n",total_pkt_recvd);
printf("Total Packets Dropped 		:	%d\n",total_pkt_drop);
printf("Total Packets Forwarded 	:	%d\n", total_pkt_forwarded);

pkt_delivery_ratio = (total_pkt_recvd/total_pkt_sent)*100;

printf("Packet Delivery Ratio 		:	%.2f%\n",pkt_delivery_ratio);

printf("The total hop counts are 	:	%d\n", total_hop_count);

avg_hop_count = total_hop_count/total_pkt_recvd;
printf("Average Hop Count 		:	%d hops\n", avg_hop_count);

printf("Routing Overhead 		:	%d\n", overhead);

printf("Normalized Routing Load 	:	%.4f\n", overhead/total_pkt_recvd);

printf("Througphut of the network(KBps)	:	%.4f\n", ((total_pkt_recvd/1000)*512)/1024);

# For End to End Delay

for ( i in end_time ) {
 start = start_time[i];
 end = end_time[i];
 packet_duration = end - start;
 if ( packet_duration > 0 )  { sum += packet_duration; recvnum++; }
}
 
delay=sum/recvnum;

printf("Average End to End Delay 	:%.9f ms\n", delay);

# Below change 50 to number of nodes that u want

printf("Total Energy Consumed  		:%.6f\n", (50*10000)-total_energy_consumed);

# Below change 50 to number of nodes that u want

printf("Protocol Energy Consumption 	:%.6f\n", 100.000000-((total_energy_consumed/(50*10000.000000))*100.000000));
		

if(((total_pkt_recvd + total_pkt_drop)/total_pkt_sent)==1) {
printf("Statistics Correct !!!");
}
}
