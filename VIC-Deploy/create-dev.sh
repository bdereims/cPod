#scp root@vic.cpod-vic.shwrfr.mooo.com:/data/harbor/cert/ca.crt harnor-ca.crt
#

./vic-machine-linux create --target  vcsa.cpod-vic.shwrfr.mooo.com --user administrator@vsphere.local --password VMware1! --thumbprint 70:7D:77:B6:ED:DE:B2:83:80:34:50:82:5D:CA:9A:A4:FF:BF:40:14 --bridge-network vxw-dvs-17-virtualwire-3-sid-5002-dev-bridge --image-store Datastore --no-tlsverify --management-network DPortGroup --client-network DPortGroup --public-network vxw-dvs-17-virtualwire-2-sid-5001-external --name vch-dev --registry-ca=harbor-ca.crt --compute-resource Cluster --volume-store 'Datastore/vch-dev-store'/volumes:default
