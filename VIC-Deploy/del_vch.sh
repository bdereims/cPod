#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

./vic-machine-linux delete --target ${TARGET} --force \
--user ${ADMIN} --password ${VC_PASSWORD} \
--compute-resource ${CLUSTER} --name ${VCH} \
--force
