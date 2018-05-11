#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod> <owner's email alias (ex: bdereims)>" && exit 1 

if [ "${2}" ==  "" ]; then
	OWNER="admin"
else
	OWNER="${2}"
fi

DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

mutex() {
	while [ -f lock ]
	do
		echo "Waiting..."
		sleep 1
	done

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
	sed -i "/\t${1}.*$/d" ${HOSTS} 

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

test_owner() {
	LINE=$( grep ${CPOD_NAME_LOWER} /etc/hosts | cut -f3 | sed "s/#//" | head -1 )
	if [ "${LINE}" != "" ] && [ "${LINE}" != "${OWNER}" ]; then
		echo "Error: Not Ok for deletion"
		./extra/post_slack.sh ":wow: *${OWNER}* you're not allowed to delete *${NAME_HIGH}*"
		exit 1
	fi
}

main() {
	CPOD_NAME="cpod-$1"
	CPOD_NAME_HIGH=$( echo ${CPOD_NAME} | tr '[:lower:]' '[:upper:]' )
        CPOD_NAME_LOWER=$( echo ${CPOD_NAME} | tr '[:upper:]' '[:lower:]' )
	NAME_HIGH=$( echo $1 | tr '[:lower:]' '[:upper:]' )

	test_owner ${2}

	#printf "Are you sure to delete ${1}? Enter to continue or CTRL+C to abort"
	#read $GO

	./extra/post_slack.sh "Deleting cPod '*${NAME_HIGH}*'"
	mutex

	echo "=== Deleting cPod called '${NAME_HIGH}'."

	IP=$( cat ${HOSTS} | grep ${CPOD_NAME_LOWER} | cut -f1 )

	bgp_delete_peer ${IP}
	vapp_delete ${NAME_HIGH}
	sleep 15
	network_delete ${NSX_TRANSPORTZONE} ${CPOD_NAME_LOWER}
	modify_dnsmasq ${CPOD_NAME_LOWER}

	echo "=== Deletion is finished."
	./extra/post_slack.sh ":thumbsup: cPod '*${NAME_HIGH}*' has been deleted"
	exit_gate 0
}

main $1
