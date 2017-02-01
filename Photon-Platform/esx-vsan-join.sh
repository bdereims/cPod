#!/bin/bash 
#bdereims@vmware.com

###
### Prepare nested ESX with vSAN 
### $1 : env configuration 
###

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}
. ./esx-utils.sh

### Local vars ####

###################

UUID=$(rexec ${ESX[0]} "esxcli system uuid get" 2>&1)
UUID=$(echo $UUID | cut -d ' ' -f 22)

for HOST in ${ESX[@]} ;
do
        echo -e "\e[7m### ${HOST} ###\e[0m"
	rexec ${HOST} "esxcli vsan cluster join -u ${UUID}"
done
