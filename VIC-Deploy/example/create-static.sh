#scp root@vic.cpod-vic.shwrfr.mooo.com:/data/harbor/cert/ca.crt harnor-ca.crt
#

./vic-machine-linux create --target  vcsa.cpod-vic.shwrfr.mooo.com --user administrator@vsphere.local --password VMware1! \
--thumbprint 70:7D:77:B6:ED:DE:B2:83:80:34:50:82:5D:CA:9A:A4:FF:BF:40:14 \
--image-store VSAN-Cluster \
--no-tlsverify \
--no-tls \
--bridge-network vxw-dvs-17-virtualwire-10-sid-5004-vch-static-bridge \
--bridge-network-range 172.16.0.0/12 \
--public-network DPortGroup \
--public-network-ip 172.18.1.35/24 \
--public-network-gateway 172.18.1.1 \
--container-network DPortGroup \
--container-network-gateway 'DPortGroup':172.18.1.1/24 \
--container-network-dns 'DPortGroup':172.18.1.1 \
--container-network-ip-range 'DPortGroup':172.18.1.80-172.18.1.89 \
--dns-server 172.18.1.1 \
--name vch-static \
--registry-ca=harbor-ca.crt \
--compute-resource Cluster \
--volume-store 'VSAN-Cluster/vch-static-store'/volumes:default
