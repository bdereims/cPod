DNSMASQ=dnsmasq.conf
HOSTS=/etc/hosts

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

echo "Next IP: ${TRANSIT_IP}"
