#!/bin/bash 
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

K8S=kubernetes-1.4.3-pc-1.1.0-5de1cb7.ova
DEL_ENV=/tmp/del_k8s.sh
TMP=/tmp/$$
TENANT=Demo
PROJECT=demo-project

###################

function mk_del {
	echo $1 >> ${TMP} 
}

function pauth {
	photon target set -c https://${PCONTROLLER}:443 
	photon target login --username administrator@cpod.net --password VMware1!

	TENANT_ID=`photon tenant list | grep ${TENANT} | cut -d' ' -f1`
	photon tenant set ${TENANT} 

	PROJECT_ID=`photon project list | grep ${PROJECT} | cut -d' ' -f1`
	photon project set ${PROJECT} 
}

pauth

photon -n image create ${BITS}/${K8S} -n ${K8S} -i EAGER

#Because the auth timeout
pauth

IMAGE_ID=`photon image list | grep ${K8S} | cut -d' ' -f1`
mk_del "photon -n image delete ${K8S}"

DEPLOYMENT_ID=`photon deployment list | head -n 2 | tail -1`

photon -n deployment enable-cluster-type ${DEPLOYMENT_ID} -k KUBERNETES -i ${IMAGE_ID} 
photon -n cluster create -n K8s -k KUBERNETES --dns ${DNS} --gateway ${GATEWAY} --netmask ${NETMASK} \
--master-ip ${K8S_IP} --container-network 10.254.0.0/16 --etcd1 ${ETCD_IP} -c 2 \
-v photon-vm -d photon-disk 

mk_del "photon target login --username administrator@cpod.net --password VMware1!"
mk_del "photon target set -c https://${PCONTROLLER}:443"
mk_del "#auto-generated during prep"
mk_del "#!/bin/bash"
tac ${TMP} > ${DEL_ENV}
chmod +x ${DEL_ENV}
rm ${TMP}
