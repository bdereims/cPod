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

echo -e "\n\nThink about to delete photon-controller-01 VM, it's error prone to redeploy on the same controller.\n"
