#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

HOSTS=/etc/hosts

main() {
	echo "=== Preparing cPod called '$1'."

	CPOD_NAME="cpod-$1"
	CPOD_NAME_LOWER=$( echo ${CPOD_NAME} | tr '[:upper:]' '[:lower:]' )
	IP=$( cat ${HOSTS} | grep ${CPOD_NAME_LOWER} | cut -f1 )

	scp -o StrictHostKeyChecking=no compute/prep_and_add_esx.sh root@${CPOD_NAME_LOWER}:.
	ssh -o StrictHostKeyChecking=no root@${CPOD_NAME_LOWER} "./prep_and_add_esx.sh"
}

main $1
