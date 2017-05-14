#!/bin/bash -x 
#bdereims@vmware.com

###
### Add NFS Datastore to all ESX
### $1 : env configuration 
###

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}
. ./esx-utils.sh

### Local vars ####

NAME=Datastore
MOUNTDIR=/data/Datastore
NFSSERVER=172.18.2.1

###################

for HOST in ${ESX[@]} ;
do
        echo -e "\e[7m### ${HOST} ###\e[0m"
	rexec ${HOST} "esxcli storage nfs add --host=${NFSSERVER} --share=${MOUNTDIR} --volume-name=${NAME}"
done
