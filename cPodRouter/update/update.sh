#!/bin/bash
#bdereims@vmware.com

[ "$( hostname )" == "mgmt-cpodrouter" ] && exit 1

### Input
# $1: name, ex: vcd
# $2: external ip, ex: 172.16.0.16

### Variables
# internal ip = last byte of $1 - 10, ex: 172.18.6.1
# dhcp low = extanel ip but with .200, ex: 172.18.6.200
# dhcp high = extanel ip but with .254, ex: 172.18.6.254
# subnet, ex. 172.18.6.0/24

### Files to be modified
# /etc/hostname
# /etc/hosts
# /etc/dnsmasq.conf
# /etc/exports
# /etc/issue
# /etc/quagga/bgpd.conf
# /etc/systemd/networkd/eth0-static.network
# /etc/systemd/networkd/eth1-static.network

### Constant
NET_INT="172.18"

if [ "$1" == "" -o  "$2" == "" ]; then
	exit 1
fi

NAME=$( echo $1 | tr '[:upper:]' '[:lower:]' )
echo $NAME

IP_TRANSIT=$2
echo ${IP_TRANSIT}

TEMP=$( echo ${IP_TRANSIT} | cut -d '.' -f4 )
NET=$( expr ${TEMP} - 10 )
IP="${NET_INT}.${NET}.1"
echo $IP

TEMP=$( echo ${IP} | sed 's/\.[0-9]*$//' )
DHCP_LOW="${TEMP}.200"
DHCP_HIGH="${TEMP}.254"
SUBNET="${TEMP}.0/24"
echo ${DHCP_LOW}
echo ${DHCP_HIGH}
echo ${SUBNET}

# hostname
echo "### hostname"
cat hostname | sed "s/###NAME###/${NAME}/" > /etc/hostname

# hosts
echo "### hosts"
cat hosts | sed "s/###IP###/${IP}/" > /etc/hosts

# dnsmasq.conf
echo "### dnsmasq.conf"
cat dnsmasq.conf | sed -e "s/###NAME###/${NAME}/" -e "s/###IP-TRANSIT###/${IP_TRANSIT}/" -e "s/###IP###/${IP}/" -e "s/###DHCP-LOW###/${DHCP_LOW}/" -e "s/###DHCP-HIGH###/${DHCP_HIGH}/" > /etc/dnsmasq.conf

# exports
echo "### exports"
cat exports | sed "s!###SUBNET###!${SUBNET}!" > /etc/exports

# issue 
echo "### issue"
cat issue | sed "s/###NAME###/${NAME}/" > /etc/issue

# bgpd.conf
echo "### bgpd.conf"
cat bgpd.conf | sed "s/###IP-TRANSIT###/${IP_TRANSIT}/" > /etc/quagga/bgpd.conf

# eth0-static.network
echo "### eth0-static.network"
cat eth0-static.network | sed "s/###IP###/${IP}/" > /etc/systemd/network/eth0-static.network

# eth1-static.network
echo "### eth1-static.network"
cat eth1-static.network | sed "s/###IP-TRANSIT###/${IP_TRANSIT}/" > /etc/systemd/network/eth1-static.network

# enable services
systemctl enable bgpd
systemctl enable dnsmasq 
systemctl enable nfs-server 

