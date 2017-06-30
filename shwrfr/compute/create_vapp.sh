#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_vapp>" && exit 1 

PS_SCRIPT=create_vapp.ps1

SCRIPT_DIR=/tmp/scripts
SCRIPT=/tmp/scripts/$$.ps1

mkdir -p ${SCRIPT_DIR} 
cp ${COMPUTE_DIR}/${PS_SCRIPT} ${SCRIPT} 

sed -i -e "s/###VCENTER###/${VCENTER}/" \
-e "s/###VCENTER_ADMIN###/${VCENTER_ADMIN}/" \
-e "s/###VCENTER_PASSWD###/${VCENTER_PASSWD}/" \
-e "s/###VCENTER_DATACENTER###/${VCENTER_DATACENTER}/" \
-e "s/###VCENTER_CLUSTER###/${VCENTER_CLUSTER}/" \
-e "s/###PORTGTOUP###/${2}/" \
-e "s/###CPOD_NAME###/${1}/" \
-e "s/###TEMPLATE_VM###/${TEMPLATE_VM}/" \
${SCRIPT}

echo "Creating vApp '${HEADER}-${1}'."
docker run --rm -it -v ${SCRIPT_DIR}:${SCRIPT_DIR} vmware/powerclicore:ubuntu14.04 powershell ${SCRIPT} 2>&1 > /dev/null

rm -fr ${SCRIPT}
