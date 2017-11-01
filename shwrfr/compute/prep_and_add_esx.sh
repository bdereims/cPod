#!/bin/bash
#bdereims@vmware.com

DHCP_LEASE=/var/lib/misc/dnsmasq.leases
DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts
PASSWORD=###ROOT_PASSWD###

[ "$( hostname )" == "mgmt-cpodrouter" ] && exit 1
[ -f already_prep ] && exit 0

touch already_prep

# waiting for all esx, boot takes time
sleep 60

I=$( cat ${DHCP_LEASE} | wc -l )
for ESX in $( cat ${DHCP_LEASE} | cut -f 2,3 -d' ' | sed 's/\ /,/' ); do
	IP=$( echo ${ESX} | cut -f2 -d',' )
	BASEIP=$( echo ${IP} | sed 's/\.[0-9]*$/./' )
	CPODROUTER="${BASEIP}1"
	NEWIP=$( expr ${I} + 10 )
	NEWIP="${BASEIP}${NEWIP}"
	NAME=$( printf "esx-%02d" ${I} )
	printf "${NEWIP}\t${NAME}\n" >> ${HOSTS}
	I=$( expr ${I} - 1 )
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no root@${IP} "esxcli system hostname set --host=${NAME}"
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no root@${IP} "vim-cmd hostsvc/vmotion/vnic_set vmk0"
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no root@${IP} "esxcli storage nfs add --host=${CPODROUTER} --share=/data/Datastore --volume-name=Datastore"
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no root@${IP} "esxcli network ip interface ipv4 set -i vmk0 -I ${NEWIP} -N 255.255.255.0 -t static ; esxcli network ip interface set -e false -i vmk0 ; esxcli network ip interface set -e true -i vmk0"
done

printf "${BASEIP}10\tpsc\n" >> ${HOSTS}
printf "${BASEIP}9\tvcsa\n" >> ${HOSTS}
printf "${BASEIP}8\tnsx-v\n" >> ${HOSTS}
printf "#${BASEIP}4-6\tnsx-v controllers\n" >> ${HOSTS}
printf "${BASEIP}7\tedgegw-v\n" >> ${HOSTS}
touch /data/Datastore/exclude.tag
touch /data/TEMP/exclude.tag
	
systemctl stop dnsmasq ; systemctl start dnsmasq 
