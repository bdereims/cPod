#!/bin/bash
#bdereims@vmware.com

DHCP_LEASE=/var/lib/misc/dnsmasq.leases
DNSMASQ=/etc/dnsmasq.conf
HOSTS=/etc/hosts

I=1

for ESX in $( cat ${DHCP_LEASE} | sort -k3 | cut -f 2,3 -d' ' | sed 's/\ /,/' ); do
	echo "dhcp-host=${ESX}" >> ${DNSMASQ}
	IP=$( echo ${ESX} | cut -f2 -d',' )
	NAME=$( printf "esx-%02d" ${I} )
	printf "${IP}\t\t${NAME}\n" >> ${HOSTS}
	I=$( expr ${I} + 1 )
	systemctl stop dnsmasq ; systemctl start dnsmasq 
	sshpass -p VMware1! ssh -o StrictHostKeyChecking=no root@${IP} "esxcli system hostname set --host=${NAME}"
	sshpass -p VMware1! ssh -o StrictHostKeyChecking=no root@${IP} "esxcli network ip interface set -e false -i vmk0; esxcli network ip interface set -e true -i vmk0"
done
