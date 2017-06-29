#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

network_env() {
	TRANSIT_IP=$( cat last_ip )
	TMP=$( echo ${TRANSIT_IP} | sed 's/.*\.//' )
	TMP=$( expr ${TMP} + 1 )

	[ ${TMP} -gt 254 ] && echo "! Impossible to create cPod. Maximum is reached." && exit_gate 1

	BASE_IP=$( cat last_ip | sed 's/\.[0-9]*$//' )
	NEXT_IP=${BASE_IP}.${TMP}

	ping -c 1 ${NEXT_IP} 2>&1 > /dev/null
	[ $? -lt 1 ] && echo "! Impossible to create cPod. '${NEXT_IP}' is already taken, verify last_ip file." && exit_gate 1

	TMP=$( expr ${TMP} - 10 )
	SUBNET=172.18.${TMP}."0/24"
	echo ${NEXT_IP} > last_ip

	echo "The cPod IP address is '${NEXT_IP}' in transit network."
	echo "The subnet of the cPod is '${SUBNET}'."
}

mutex() {
	[ -f lock ] && echo "A cPod creation is running, please launch later." && exit 1
	touch lock
}

network_create() {
	NSX_LOGICALSWITCH=$( echo $1 | tr '[:upper:]' '[:lower:]' )
	NSX_LOGICALSWITCH="cpod-${NSX_LOGICALSWITCH}"
	${NETWORK_DIR}/create_logicalswitch.sh ${NSX_TRANSPORTZONE} ${NSX_LOGICALSWITCH}
}

exit_gate() {
	rm -fr lock
	exit $1 
}

main() {
	echo "=== Starting to deploy a new cPod called '$1'."
	mutex

	network_env
	network_create $1

	echo "=== Creation is finished."
	exit_gate 0
}

main $1 $2
