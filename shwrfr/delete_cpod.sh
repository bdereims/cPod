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

modify_dnsmasq() {
	echo "Modifying '${DNSMASQ}' and '${HOSTS}'."
	sed -i "/${1}/d" ${DNSMASQ} 
	sed -i "/${1}/d" ${HOSTS} 

	systemctl stop dnsmasq 
        systemctl start dnsmasq
}

release_mutex() {
	rm -fr lock
}

exit_gate() {
	release_mutex
	exit $1 
}

main() {
	mutex
	echo "=== Deleting cPod called '$1'."

	CPOD_NAME="cpod-$1"
	CPOD_NAME_LOWER=$( echo ${CPOD_NAME} | tr '[:upper:]' '[:lower:]' )

	network_delete ${NSX_TRANSPORTZONE} ${CPOD_NAME_LOWER}
	modify_dnsmasq ${CPOD_NAME_LOWER}

	echo "=== Deletion is finished."
	exit_gate 0
}

main $1 $2
