#!/bin/bash
#bdereims@vmware.com

###
### Prepare nested ESX to be safely cloned
### $1 : env configuration 
### $2 : ESX @IP
###

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}
. ./esx-utils.sh

### Local vars ####

###################

rexec ${2} "esxcli system settings advanced set -o /Net/FollowHardwareMac -i 1"
rexec ${2} "sed -i 's#/system/uuid.*##' /etc/vmware/esx.conf"
rexec ${2} "echo hv.assumeEnabled = TRUE >> /etc/vmware/config"
#rexec ${2} "echo vmx.allowNested = TRUE >> /etc/vmware/config"
#rexec ${2} "/sbin/auto-backup.sh"
rpoweroff ${2}
