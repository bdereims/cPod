#!/bin/bash
#bdereims@vmware.com

###
### Destroy Photon environnement 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}
. ./esx-utils.sh

### Local vars ####

###################

photon target set http://${PCIP}:9000
photon system destroy 

for HOST in ${ESX[@]} ;
do
	rexec ${HOST} "esxcli software vib remove -n photon-controller-agent"
done

