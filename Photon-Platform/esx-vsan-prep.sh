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

CACHE="t10.ATA_____QEMU_HARDDISK___________________________QM00002_____________"
DATA="t10.ATA_____QEMU_HARDDISK___________________________QM00003_____________"

for HOST in ${ESX[@]} ;
do
        echo -e "\e[7m### ${HOST} ###\e[0m"
	rexec ${HOST} "esxcli vsan network ipv4 add -i vmk0"
	rexec ${HOST} "esxcli storage nmp satp rule add --satp=VMW_SATP_LOCAL --device ${SSD} --option enable_ssd"
	rexec ${HOST} "esxcli storage core claiming unclaim --type=device --device ${SSD}"
	rexec ${HOST} "esxcli storage core claimrule load"
	rexec ${HOST} "esxcli storage core claimrule run"
	rexec ${HOST} "esxcli storage core claiming reclaim  --device ${CACHE}"
	rexec ${HOST} "vdq -q"
	rexec ${HOST} "esxcli vsan storage add -d ${DATA} -s ${CACHE}" 
done
