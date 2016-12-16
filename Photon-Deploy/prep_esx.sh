#!/bin/bash 
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

function rexec {
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	${ADMIN}@${1} $2
}

for i in ${ESX_IPS[@]} ;
do
	echo "### ${i} ###"
	rexec ${i} "esxcli vsan network ipv4 add -i vmk0"
done
