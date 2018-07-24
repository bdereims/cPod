#!/bin/bash
#jacobssimon@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name of cpod>, then the script automatically license vCenter, vSphere and vSAN if any" && exit 1

#==========LICENSE KEYS==========

#vCenter 6 std 16 CPUs exp 04/2021

KEYS[0]=K44J6-C4H5Q-E80D8-0K126-8NE7K

#vSphere 6 ent plus 64 cpus exp 04/2021

KEYS[1]=5N0R6-GDK0N-E8999-0T4R2-CX5HP

#vSan 6 ent 32 cpus exp 01/2020

KEYS[2]=EJ6LQ-E8213-R82ER-0AD22-2ME3L

#NSX V Ent 32 cpus never exp

KEYS[3]=R00U4-8WJDP-J83D9-0U904-38T0L

#==========CONNECTION DETAILS==========

POD_NAME="cPod-${1}"
POD_FQDN="${POD_NAME}.shwrfr.mooo.com"
GOVC_LOGIN="administrator@${POD_FQDN}"
GOVC_PWD="VMware1!"
GOVC_URL="https://${GOVC_LOGIN}:${GOVC_PWD}@vcsa.${POD_FQDN}"
GOVC_URL2=$GOVC_URL

#======================================

main() {
	echo "Connecting vcsa.${POD_FQDN} ..."
	
	for i in {0..3}
	do
		govc license.add -k=true -u=${GOVC_URL2} ${KEYS[i]}
	done
	govc license.assign -k=true -u=${GOVC_URL2} ${KEYS[0]}
	
	NUM_ESX="$(govc datacenter.info -k=true -u=${GOVC_URL2} /"${POD_NAME}" | grep "Hosts" | cut -d : -f 2 | cut -d " " -f 14)"
	
	for (( i=1; i<=$NUM_ESX; i++ ))
	do
		HOST="esx-0${i}.${POD_FQDN}"
		govc license.assign -k=true -u=${GOVC_URL2} -host ${HOST,,} ${KEYS[1]}
	done
	
	govc license.ls -k=true -u=${GOVC_URL2}
}

main
