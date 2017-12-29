#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

mutex() {
	[ -f lock ] && echo "A cPod creation is running, please launch later." && exit 1
	touch lock
}

network_delete() {
	${NETWORK_DIR}/delete_logicalswitch.sh ${1} ${2}
}

vapp_delete() {
	${COMPUTE_DIR}/delete_vapp.sh ${1}
}

modify_dnsmasq() {
	echo "Modifying '${DNSMASQ}' and '${HOSTS}'."
	sed -i "/${1}./d" ${DNSMASQ} 
	sed -i "/\t${1}$/d" ${HOSTS} 

	systemctl stop dnsmasq 
        systemctl start dnsmasq
}

bgp_delete_peer() {
	./network/delete_bgp_neighbour.sh edge-6 ${1}
}

release_mutex() {
	rm -fr lock
}

exit_gate() {
	release_mutex
	exit $1 
}

main() {
	printf "Are you sure to delete ${1}? Enter to continue or CTRL+C to abort"
	read $GO

	./extra/post_slack.sh "Deleting cPod *'${HEADER}-${1}'*"
	mutex

	echo "=== Deleting cPod called '$1'."

	CPOD_NAME="cpod-$1"
	CPOD_NAME_LOWER=$( echo ${CPOD_NAME} | tr '[:upper:]' '[:lower:]' )
	IP=$( cat ${HOSTS} | grep ${CPOD_NAME_LOWER} | cut -f1 )

	bgp_delete_peer ${IP}
	vapp_delete ${1}
	sleep 15
	network_delete ${NSX_TRANSPORTZONE} ${CPOD_NAME_LOWER}
	modify_dnsmasq ${CPOD_NAME_LOWER}

	echo "=== Deletion is finished."
	./extra/post_slack.sh ":thumbsup: cPod *'${HEADER}-${1}'* has been deleted"
	exit_gate 0
}

main $1
