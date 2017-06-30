#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

network_env() {
	TRANSIT_IP=$( grep "cpod-" ${DNSMASQ} | sed 's!^.*/!!' | sort | tail -n 1 )
	TMP=$( echo ${TRANSIT_IP} | sed 's/.*\.//' )
	TMP=$( expr ${TMP} + 1 )

	[ ${TMP} -gt 253 ] && echo "! Impossible to create cPod. Maximum is reached." && exit_gate 1

	BASE_IP=$( echo ${TRANSIT_IP} | sed 's/\.[0-9]*$//' )
	NEXT_IP=${BASE_IP}.${TMP}

	ping -c 1 ${NEXT_IP} 2>&1 > /dev/null
	[ $? -lt 1 ] && echo "! Impossible to create cPod. '${NEXT_IP}' is already taken, verify last_ip file." && exit_gate 1

	TMP=$( expr ${TMP} - 10 )
	SUBNET=172.18.${TMP}."0/24"

	echo "The cPod IP address is '${NEXT_IP}' in transit network."
	echo "The subnet of the cPod is '${SUBNET}'."
}

mutex() {
	[ -f lock ] && echo "A cPod creation is running, please launch later." && exit 1
	touch lock
}

network_create() {
	NSX_LOGICALSWITCH="cpod-${NAME_LOWER}"
	${NETWORK_DIR}/create_logicalswitch.sh ${NSX_TRANSPORTZONE} ${NSX_LOGICALSWITCH}

	PORTGROUP=$( ${NETWORK_DIR}/list_logicalswitch.sh ${NSX_TRANSPORTZONE} | jq 'select(.name == "'${NSX_LOGICALSWITCH}'") | .portgroup' | sed 's/"//g' )
	PORTGROUP_NAME=$( ${COMPUTE_DIR}/list_portgroup.sh | jq 'select(.network == "'${PORTGROUP}'") | .name' | sed 's/"//g' )

	${COMPUTE_DIR}/modify_portgroup.sh ${PORTGROUP_NAME}
}

vapp_create() {
	${COMPUTE_DIR}/create_vapp.sh ${1} ${2} 
	sleep 45
	sshpass -p VMware1! ssh root@172.16.0.254 "cd update ; ./update.sh ${1} ${3} ; reboot"
}

modify_dnsmasq() {
	echo "Modifying '${DNSMASQ}' and '${HOSTS}'."
	echo "server=/cpod-${1}.shwrfr.mooo.com/${2}" >> ${DNSMASQ}
	echo "${2} cpod-${1}" >> ${HOSTS}

	systemctl stop dnsmasq
	systemctl start dnsmasq
}

exit_gate() {
	rm -fr lock
	exit $1 
}

main() {
	echo "=== Starting to deploy a new cPod called '${HEADER}-${1}'."
	mutex

	NAME_LOWER=$( echo $1 | tr '[:upper:]' '[:lower:]' )

	network_env
	network_create ${NAME_LOWER}
	modify_dnsmasq ${NAME_LOWER} ${NEXT_IP}
	vapp_create ${1} ${PORTGROUP_NAME} ${NEXT_IP}

	echo "=== Creation is finished."
	exit_gate 0
}

main $1 $2
