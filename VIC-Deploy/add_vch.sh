#!/bin/bash 
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

./vic-machine-linux create --target ${TARGET} --user ${ADMIN} \
--password "${PASSWORD}" --compute-resource ${CLUSTER} --image-store ${DATASTORE} --name ${VCH} --no-tlsverify \
--bridge-network "${BRIDGE}" --management-network "${PORTGROUP}" \
--public-network "${PORTGROUP}" --client-network "${PORTGROUP}" \
--force 
