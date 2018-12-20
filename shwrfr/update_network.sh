#!/bin/bash

exit 0

CPOD=$( cat /etc/hosts | grep "172.16" | grep "cpod-" | awk '{print $1}' )

for THEIP in $CPOD;
do
	echo ${THEIP}
	scp update_network_cpodrouter.sh ${THEIP}:.
	ssh ${THEIP} "bash update_network_cpodrouter.sh"
	
	./network/add_bgp_peer_vtysh.sh ${THEIP} 65001

	./network/delete_bgp_neighbour.sh edge-6 ${THEIP}
done
