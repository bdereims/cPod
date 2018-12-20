#!/bin/bash

exit 0

ip route delete default
ip route add default via 172.16.0.6

sed -i "s/neighbor 172.16.0.2 remote-as 65001/neighbor 172.16.0.6 remote-as 65000/" /etc/quagga/bgpd.conf
systemctl restart bgpd

sed -e "s/10.50.0.3/172.16.0.6/g" -e "s/8.8.8.8/172.16.0.6/g" -i /etc/dnsmasq.conf
systemctl restart dnsmasq
