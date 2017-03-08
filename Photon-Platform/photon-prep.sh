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

photon target set http://${PCIP}:9000
photon system deploy ${CONFDIR}/${PHOTONENV} 
