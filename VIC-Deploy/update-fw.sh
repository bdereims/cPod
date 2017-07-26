#!/bin/bash

#scp root@vic.cpod-vic.shwrfr.mooo.com:/data/harbor/cert/ca.crt harnor-ca.crt

VCSA=vcsa.cpod-vic.shwrfr.mooo.com
DATASTORE=Datastore
PORTGROUP=DPortGroup

./vic-machine-linux update firewall --target ${VCSA} --user administrator@vsphere.local --password VMware1! --allow --thumbprint $( ./thumbprint ${VCSA} ) 
