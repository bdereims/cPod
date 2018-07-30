#!/bin/bash
#bdereims@vmware.com

# Usage : ./create_cpod.sh EUC (not cPod-EUC)

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod> <number_of_esx (default = 3)> <owner's email alias (ex: bdereims)>" && exit 1 

if [ "${2}" ==  "" ]; then
	NUM_ESX="3"
else
	NUM_ESX="${2}"
fi

if [ "${3}" ==  "" ]; then
	OWNER="admin"
else
	OWNER="${3}"
fi

#========================================================================================

DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

network_env() {
	#TRANSIT_IP=$( grep "cpod-" ${DNSMASQ} | sed 's!^.*/!!' | sort | tail -n 1 )
	#TMP=$( echo ${TRANSIT_IP} | sed 's/.*\.//' )
	#TMP=$( expr ${TMP} + 1 )

	FIRST_LINE=$( grep "cpod-" ${DNSMASQ} | awk -F "/" '{print $3}' | sort -n -t "." -k 7 | head -1 )
	LAST_LINE=$( grep "cpod-" ${DNSMASQ} | awk -F "/" '{print $3}' | sort -n -t "." -k 7 | tail -1 )

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
	${COMPUTE_DIR}/create_vapp.sh ${NAME_UPPER} ${2} ${3} ${4} ${5}
}

modify_dnsmasq() {
	echo "Modifying '${DNSMASQ}' and '${HOSTS}'."
	echo "server=/cpod-${1}.${ROOT_DOMAIN}/${2}" >> ${DNSMASQ}
	#GEN_PASSWORD=$( pwgen -s -N 1 -n -c -y 10 | sed -e 's/\\/!/' -e 's/;/-/' -e 's/"/$/' -e 's/&/!/' -e "s#'#[#" )
	GEN_PASSWORD="$(pwgen -s -1 15 1)!"
	printf "${2}\tcpod-${1}\t#${OWNER}\t${GEN_PASSWORD}\n" >> ${HOSTS}

	systemctl stop dnsmasq ; systemctl start dnsmasq
}

bgp_add_peer() {
	echo "Adding cPodRouter as BGP peer"
	./network/add_bgp_neighbour.sh $1 $2 
}

prep_cpod() {
	./prep_cpod.sh $1
}

exit_gate() {
	[ -f lock ] && rm lock
	exit $1 
}

check_space() {
	./extra/check_space.sh
	if [ $? != 0 ]; then
		echo "Error: No more space, can't continue."
		./extra/post_slack.sh ":thumbsdown: Can't create cPod *${1}*, no more space on Datastore."
		exit_gate 1
	fi
}

main() {
	check_space $1

	echo "=== Starting to deploy a new cPod called '${HEADER}-${1}'."
	./extra/post_slack.sh "Starting creation of cPod *${1}*"
	START=$( date +%s ) 
	
	NAME_LOWER=$( echo $1 | tr '[:upper:]' '[:lower:]' )

	mutex
	network_env
	network_create ${NAME_LOWER}
	modify_dnsmasq ${NAME_LOWER} ${NEXT_IP} ${3}
	de_mutex

	vapp_create ${1} ${PORTGROUP_NAME} ${NEXT_IP} ${NUM_ESX} ${ROOT_DOMAIN}

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
	./extra/post_slack.sh ":thumbsup: cPod *${1}* has been successfully created in *${TIME}s*"

	exit_gate 0
}

main $1
