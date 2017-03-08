#!/bin/bash
#bdereims@vmware.com

###
### Create a Photon demo tenant
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

PHOTONOS=photon-custom-hw11-1.0-13c08b6.ova
DEL_ENV=/tmp/del_photon.sh
TMP=/tmp/$$
TENANT=Demo
PROJECT=demo-project
VN_NAME=vm-1

###################

function mk_del {
	echo $1 >> ${TMP} 
}

echo -e "Did you create a Port Group called \e[1m'Photon Network'\e[0m?"
read -n 1 -s -p "Press any key to continue"
echo -e "\n"

#photon target set http://${PCONTROLLER}:28080
photon target set -c https://${LB}:443 
photon target login --username administrator@cpod.net --password VMware1!

photon -n tenant create ${TENANT} 
TENANT_ID=`photon tenant list | grep ${TENANT} | cut -d' ' -f1`
mk_del "photon -n tenant delete ${TENANT_ID}"
photon tenant set ${TENANT} 

photon -n resource-ticket create --name gold-ticket --limits "vm.memory 20 GB, vm 10 COUNT"

photon -n project create --resource-ticket gold-ticket --name ${PROJECT} --limits "vm.memory 20 GB, vm 10 COUNT"
PROJECT_ID=`photon project list | grep ${PROJECT} | cut -d' ' -f1`
mk_del "photon -n project delete ${PROJECT_ID}"
photon project set ${PROJECT} 

echo "Importing PhotonOS OVA, should take time!"
photon -n image create ${BITS}/${PHOTONOS} -n ${PHOTONOS} -i EAGER
IMAGE_ID=`photon image list | grep ${PHOTONOS} | cut -d' ' -f1`
mk_del "photon -n image delete ${IMAGE_ID}"

photon -n flavor create --name photon-vm --kind "vm" --cost "vm.cpu 1.0 COUNT, vm.memory 1.0 GB, vm.cost 1.0 COUNT"
FLAVOR_VM_ID=`photon flavor list | grep photon-vm | cut -d' ' -f1`
mk_del "photon -n flavor delete ${FLAVOR_VM_ID}"
photon -n flavor create --name photon-disk --kind "ephemeral-disk" --cost "ephemeral-disk 1.0 COUNT"
FLAVOR_DISK_ID=`photon flavor list | grep photon-disk | cut -d' ' -f1`
mk_del "photon -n flavor delete ${FLAVOR_DISK_ID}"

photon -n network create --name photon-network --portgroups "Photon Network" --description "Network for VMs"
NETWORK_ID=`photon network list | grep "photon-network" | cut -d' ' -f1`
mk_del "photon -n network delete ${NETWORK_ID}"
photon -n network set-default ${NETWORK_ID}

photon -n vm create --name ${VN_NAME} --image ${IMAGE_ID} --flavor photon-vm --disks "disk-1 photon-disk boot=true"
VM_ID=`photon vm list | grep ${VN_NAME} | cut -d' ' -f1`
mk_del "photon -n vm delete ${VM_ID}"
photon vm start ${VM_ID}
mk_del "photon -n vm stop ${VM_ID}"


mk_del "photon target login --username administrator@cpod.net --password VMware1!"
mk_del "photon target set -c https://${LB}:443"
mk_del "#auto-generated during prep"
mk_del "#!/bin/bash"
tac ${TMP} > ${DEL_ENV}
chmod +x ${DEL_ENV}
rm ${TMP}
echo -e "\n\nExecute ${DEL_ENV} in ${TMP} to destroy tenant."
