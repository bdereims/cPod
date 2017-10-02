#!/bin/bash
#bdereims@vmware.com

# Usage : ./create_cpod.sh EUC (not cPod-EUC)

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

network_env() {
	#TRANSIT_IP=$( grep "cpod-" ${DNSMASQ} | sed 's!^.*/!!' | sort | tail -n 1 )
	#TMP=$( echo ${TRANSIT_IP} | sed 's/.*\.//' )
	#TMP=$( expr ${TMP} + 1 )

	FIRST_LINE=$( grep "cpod-" ${DNSMASQ} | head -1 )
	LAST_LINE=$( grep "cpod-" ${DNSMASQ} | tail -1 )

	TRANSIT_SUBNET=$( echo ${FIRST_LINE} | sed 's!^.*/!!' | sed 's/\.[0-9]*$//' )

	TRANSIT_IP=$( echo ${FIRST_LINE} | sed 's!^.*/!!' | sed 's/.*\.//' )
	TRANSIT_IP=$( expr ${TRANSIT_IP} )
	LAST_IP=$( echo ${LAST_LINE} | sed 's!^.*/!!' | sed 's/.*\.//' )
	LAST_IP=$( expr ${LAST_IP} )

	while [ ${TRANSIT_IP} -le ${LAST_IP} ]
	do
        	if [[ ! $( grep "${TRANSIT_SUBNET}.${TRANSIT_IP}" ${DNSMASQ} ) ]]; then
                	break
        	fi

        	TRANSIT_IP=$( expr ${TRANSIT_IP} + 1 )
	done

	[ ${TRANSIT_IP} -gt 253 ] && echo "! Impossible to create cPod. Maximum is reached." && exit_gate 1

	NEXT_IP="${TRANSIT_SUBNET}.${TRANSIT_IP}"

	TMP=$( expr ${TRANSIT_IP} - 10 )
	SUBNET="172.18.${TMP}.0/24"

	echo "The cPod IP address is '${NEXT_IP}' in transit network."
	echo "The subnet of the cPod is '${SUBNET}'."
}

mutex() {
	while [ -f lock ]
	do
		echo "Waiting..."
		sleep 1
	done
	touch lock
}

de_mutex() {
	rm lock
}

network_create() {
	NSX_LOGICALSWITCH="cpod-${NAME_LOWER}"
	${NETWORK_DIR}/create_logicalswitch.sh ${NSX_TRANSPORTZONE} ${NSX_LOGICALSWITCH}

	PORTGROUP=$( ${NETWORK_DIR}/list_logicalswitch.sh ${NSX_TRANSPORTZONE} | jq 'select(.name == "'${NSX_LOGICALSWITCH}'") | .portgroup' | sed 's/"//g' )
	PORTGROUP_NAME=$( ${COMPUTE_DIR}/list_portgroup.sh | jq 'select(.network == "'${PORTGROUP}'") | .name' | sed 's/"//g' )

	${COMPUTE_DIR}/modify_portgroup.sh ${PORTGROUP_NAME}
}

vapp_create() {
	NAME_UPPER=$( echo ${1} | tr '[:lower:]' '[:upper:]' )
	${COMPUTE_DIR}/create_vapp.sh ${NAME_UPPER} ${2} ${3}
}

modify_dnsmasq() {
	echo "Modifying '${DNSMASQ}' and '${HOSTS}'."
	echo "server=/cpod-${1}.shwrfr.mooo.com/${2}" >> ${DNSMASQ}
	printf "${2}\tcpod-${1}\n" >> ${HOSTS}

	systemctl stop dnsmasq ; systemctl start dnsmasq
}

bgp_add_peer() {
	./network/add_bgp_neighbour.sh $1 $2 
}

prep_cpod() {
	./prep_cpod.sh $1
}

exit_gate() {
	[ -f lock ] && rm lock
	exit $1 
}

main() {
	echo "=== Starting to deploy a new cPod called '${HEADER}-${1}'."
	START=$( date +%s ) 
	
	NAME_LOWER=$( echo $1 | tr '[:upper:]' '[:lower:]' )

	mutex
	network_env
	network_create ${NAME_LOWER}
	modify_dnsmasq ${NAME_LOWER} ${NEXT_IP}
	de_mutex

	vapp_create ${1} ${PORTGROUP_NAME} ${NEXT_IP}

	mutex
	bgp_add_peer edge-6 ${NEXT_IP}
	de_mutex

	prep_cpod ${1}

	### Installation of vCenter : cd ../SDDC-Deploy ; ./deploy_vcsa.sh cpod-XXX_env
	### vCenter Prep : compute/prep_vcsa.sh cPod-XXX

	echo "=== Creation is finished."
	END=$( date +%s )
	TIME=$( expr ${END} - ${START} )
	echo "In ${TIME} Seconds."
	exit_gate 0
}

main $1
