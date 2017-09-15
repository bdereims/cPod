#scp root@vic.cpod-vic.shwrfr.mooo.com:/data/harbor/cert/ca.crt harnor-ca.crt
#

./vic-machine-linux create --target  vcsa.cpod-vic.shwrfr.mooo.com --user administrator@vsphere.local --password VMware1! \
--thumbprint 70:7D:77:B6:ED:DE:B2:83:80:34:50:82:5D:CA:9A:A4:FF:BF:40:14 \
--image-store VSAN-Cluster \
--no-tlsverify \
--no-tls \
--bridge-network vxw-dvs-17-virtualwire-6-sid-5001-vch-staging-bridge \
--management-network DPortGroup \
--client-network DPortGroup \
--public-network DPortGroup \
--name vch-staging \
--registry-ca=harbor-ca.crt \
--compute-resource Cluster \
--volume-store 'VSAN-Cluster/vch-staging-store'/volumes:default
