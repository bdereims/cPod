#!/bin/bash
#bdereims@vmware.com

###
### Demo tenant status
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

TENANT=Demo
PROJECT=demo-project

###################

photon target set -c https://${LB}:443 
photon target login --username administrator@esxcloud --password VMware1!

photon system status

TENANT_ID=`photon tenant list | grep ${TENANT} | cut -d' ' -f1`
photon tenant set ${TENANT} 

PROJECT_ID=`photon project list | grep ${PROJECT} | cut -d' ' -f1`
photon project set ${PROJECT}
