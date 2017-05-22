#!/bin/bash -x
#bdereims@vmware.com

###
### Set and deploy Photon environnement 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

TENANT="Demo"
PROJECT="cPod"
PROCJET_HABOR="Habor"

###################

photon target set -c https://${LB}:443
photon target login --username administrator@${DOMAIN} --password ${PASSWORD}

photon tenant create ${TENANT} \ 
--limits 'vm.count 100 COUNT, 
vm.cost 1000 COUNT, 
vm.memory 1000 GB, 
vm.cpu 500 COUNT, 
vm 500 COUNT, 
vm.flavor.cluster-other-vm 100 COUNT,
ephemeral-disk 1000 COUNT, 
ephemeral-disk.capacity 1000 GB, 
ephemeral-disk.cost 1000 GB,  
persistent-disk 1000 COUNT, 
persistent-disk.capacity 1000 GB, 
persistent-disk.cost 1000 GB, 
storage.LOCAL_VMFS 1000 COUNT, 
storage.VSAN 1000 COUNT, 
sdn.floatingip.size 1000 COUNT'

photon tenant set ${TENANT}

photon project create ${PROJECT} --tenant ${TENANT} --percent 80
photon project create ${PROCJET_HABOR} --tenant ${TENANT} --percent 20 

photon tenant set ${TENANT}
photon project set ${PROJECT}

photon subnet create --name "vm-network" --portgroups "VM Network" 
SUBNET_ID=$(photon subnet list | grep "VM Network" | ...) 
photon subnet set-default ${SUBNET_ID}

# Create Flavors
photon flavor create --name harbor-service-vm --kind "vm" --cost \
"vm.count 1 COUNT,vm.flavor.cluster-other-vm 1 COUNT,vm.cpu 1 COUNT,vm.memory 1 GB,vm.cost 1 COUNT" 

photon flavor create --name service-small --kind "vm" \
--cost "vm.count 1 COUNT, vm.cpu 1 COUNT, vm.memory 2 GB"

photon -n flavor create --name "vm-basic" --kind "vm" \
--cost "vm.count 1 COUNT, vm.cpu 2 COUNT, vm.memory 4 GB" 

photon -n flavor create --name "disk-eph" --kind "ephemeral-disk" \
--cost "ephemeral-disk 1 COUNT"

photon -n flavor create --name "disk-persist" --kind "persistent-disk" \
--cost "persistent-disk 1 COUNT"


### Harbor ###
# Create Images
PROJECTID=$( photon project list | grep Harbor | cut -d' ' -f1 )
photon image create --name harbor-image --image_replication ON_DEMAND --scope project --project ${PROJECTID} \
$BITS/harbor-0.4.1-pc-1.2.1-77a6d82.ova

HARBOR_IMAGE_ID=$(photon image list | grep harbor-image | cut -d' ' -f1)
photon system enable-service-type --type HARBOR --image-id ${HARBOR_IMAGE_ID}

# Create Services
photon service create --name harbor-service --type HARBOR \
--dns ${LB} --gateway ${GATEWAY} --netmask ${NETMASK} \
--master-ip ${HARBORIP} --vm_flavor harbor-service-vm \
--tenant ${TENANT} --project ${PROCJET_HABOR} --admin-password ${PASSWORD} 

photon service list

### K8s ###
PROJECTID=$( photon project list | grep cPod | cut -d' ' -f1 )
photon image create --name k8s-image --image_replication ON_DEMAND --scope project --project ${PROJECTID} \
$BITS/kubernetes-1.6.0-pc-1.2.1-77a6d82.ova

K8S_IMAGE_ID=$(photon image list | grep k8s-image | cut -d' ' -f1)
photon system enable-service-type --type KUBERNETES --image-id ${K8S_IMAGE_ID}

photon service create -n k8s-service -k KUBERNETES --tenant ${TENANT} --project ${PROJECT} \
--master-ip 172.18.2.38 --master-ip2 172.18.2.39 --load-balancer-ip 172.18.2.43 \ 
--etcd1 172.18.2.40 --etcd2 172.18.2.41 --etcd3 172.18.2.42 \
--container-network 10.2.0.0/16 --dns ${LB} --gateway ${GATEWAY} --netmask ${NETMASK} \
--worker_count 1 --master-vm-flavor service-small --worker-vm-flavor vm-basic

#photon service get-kubectl-auth -u administrator@${DOMAIN} -p '${PASSWORD} ${SERVICE_ID} 
