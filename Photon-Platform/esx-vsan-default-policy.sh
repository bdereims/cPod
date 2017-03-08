#!/bin/bash 
#bdereims@vmware.com

###
### Set the default vSAN Policy: FTT=0 STRIP=1
### $1 : env configuration 
###

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}
. ./esx-utils.sh

### Local vars ####

###################

PCLASS=(cluster vdisk vmnamespace vmswap vmem)

for HOST in ${ESX[@]} ;
do
	echo -e "\e[7m### ${HOST} ###\e[0m"
	for CLASS in ${PCLASS[@]} ;
	do	
		rexec ${HOST} "esxcli vsan policy setdefault -c ${CLASS} -p \"((\\\"hostFailuresToTolerate\\\" i0) (\\\"forceProvisioning\\\" i1) (\\\"stripeWidth\\\" i1))\""
	done
done
