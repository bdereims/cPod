#!/bin/bash 
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

<<<<<<< HEAD
./vic-machine-linux create --target ${TARGET} --user ${ADMIN} \
--password "${PASSWORD}" --compute-resource ${CLUSTER} --image-store ${DATASTORE} --name ${VCH} --no-tlsverify \
--bridge-network "${BRIDGE}" --management-network "${PORTGROUP}" \
--public-network "${PORTGROUP}" --client-network "${PORTGROUP}" \
=======
./vic-machine-linux create --target vcsa.brmc.local/DC01 --user 'administrator@vsphere.local' \
--password 'VMware1!' --compute-resource CLCOMP01 --image-store dsVSAN-COMP-01 --name VCH01 --no-tlsverify \
--bridge-network "vxw-dvs-67-virtualwire-11-sid-5008-VCH01-Bridge" --management-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" \
--public-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" --client-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" \
>>>>>>> 86fef56b1449ac850792d5e82ea7efafad554ed5
--force 
