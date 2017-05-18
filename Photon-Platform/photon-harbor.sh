#!/bin/bash
#bdereims@vmware.com

###
### Set and deploy Photon environnement 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

###################

photon target set -c https://${LB}:443
photon target login --username administrator@${DOMAIN} --password '${PASSWORD}'

photon flavor create --name harbor-cluster-vm --kind "vm" \
--cost "vm 1 COUNT,vm.flavor.cluster-other-vm 1 COUNT,vm.cpu 1 COUNT,vm.memory 1 GB,vm.cost 1 COUNT"
