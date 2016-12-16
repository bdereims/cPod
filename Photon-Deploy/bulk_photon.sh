#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

PHOTONOS=photon-custom-hw11-1.0-13c08b6.ova
DEL_ENV=/tmp/del_bulk_photon.sh
TMP=/tmp/$$
TENANT=Demo
PROJECT=demo-project
VM_NAME=bulk

###################

function mk_del {
	echo $1 >> ${TMP} 
}

#photon target set http://${PCONTROLLER}:28080
photon target set -c https://${PCONTROLLER}:443 
photon target login --username administrator@esxcloud --password VMware1!
photon tenant set ${TENANT} 
photon project set ${PROJECT}

IMAGE_ID=`photon image list | grep ${PHOTONOS} | cut -d' ' -f1`

for i in `seq 1 111`;
do
	BULK_NAME=${VM_NAME}-${i}
	photon -n vm create --name ${BULK_NAME} --image ${IMAGE_ID} --flavor photon-vm --disks "disk-1 photon-disk boot=true"
	VM_ID=`photon vm list | grep ${BULK_NAME} | cut -d' ' -f1`
	mk_del "photon -n vm delete ${VM_ID}"
	photon vm start ${VM_ID}
	mk_del "photon -n vm stop ${VM_ID}"
done

mk_del "#auto-generated during bulk prep"
mk_del "#!/bin/bash"
tac ${TMP} > ${DEL_ENV}
chmod +x ${DEL_ENV}
rm ${TMP}
