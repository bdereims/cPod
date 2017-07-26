#!/bin/bash

#scp root@vic.cpod-vic.shwrfr.mooo.com:/data/harbor/cert/ca.crt harnor-ca.crt

VCSA=vcsa.cpod-vic.shwrfr.mooo.com
DATASTORE=Datastore
PORTGROUP=DPortGroup

./vic-machine-linux create --target ${VCSA} --user administrator@vsphere.local --password VMware1! \
--thumbprint $( ./thumbprint ${VCSA} ) \
--image-store ${DATASTORE} \
--no-tlsverify \
--no-tls \
--bridge-network vxw-dvs-17-virtualwire-7-sid-5002-vch-prod-bridge \
--management-network ${PORTGROUP} \
--client-network ${PORTGROUP} \
--public-network ${PORTGROUP} \
--name vch-prod \
--registry-ca=harbor-ca.crt \
--compute-resource Cluster \
--volume-store '${DATASTORE}/vch-prod-store'/volumes:default
