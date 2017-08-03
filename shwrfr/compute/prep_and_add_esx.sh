#!/bin/bash
#bdereims@vmware.com

DHCP_LEASE=/var/lib/misc/dnsmasq.leases
DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts


I=$( cat ${DHCP_LEASE} | wc -l )
for ESX in $( cat ${DHCP_LEASE} | cut -f 2,3 -d' ' | sed 's/\ /,/' ); do
	#echo "dhcp-host=${ESX}" >> ${DNSMASQ}
	IP=$( echo ${ESX} | cut -f2 -d',' )
	BASEIP=$( echo ${IP} | sed 's/\.[0-9]*$/./' )
	NEWIP=$( expr ${I} + 10 )
	NEWIP="${BASEIP}${NEWIP}"
	NAME=$( printf "esx-%02d" ${I} )
	printf "${NEWIP}\t${NAME}\n" >> ${HOSTS}
	I=$( expr ${I} - 1 )
	sshpass -p VMware1! ssh -o StrictHostKeyChecking=no root@${IP} "esxcli system hostname set --host=${NAME}"
	sshpass -p VMware1! ssh -o StrictHostKeyChecking=no root@${IP} "esxcli network ip interface ipv4 set -i vmk0 -I ${NEWIP} -N 255.255.255.0 -t static ; esxcli network ip interface set -e false -i vmk0 ; esxcli network ip interface set -e true -i vmk0"
done

printf "${BASEIP}20\tvcsa\n" >> ${HOSTS}
printf "${BASEIP}21\tnsx\n" >> ${HOSTS}
printf "#${BASEIP}22-24\tnsx controllers\n" >> ${HOSTS}
printf "${BASEIP}25\tedgegw\n" >> ${HOSTS}
	
#systemctl stop dnsmasq ; systemctl start dnsmasq 
