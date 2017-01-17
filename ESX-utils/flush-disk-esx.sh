#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} exec-env cmd" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

function rexec {
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	${ADMIN}@${1} $2
}

function rscp {
	sshpass -p ${PASSWORD} scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	flush-disk ${ADMIN}@${1}:/tmp
}

for i in ${ESX_IPS[@]} ;
do
	echo "### ${i} ###"
	rscp ${i}
	rexec ${i} "ls -1 /dev/disks/naa* | sed -e 's/:.*//' > /tmp/disks.list"
	rexec ${i} "sh /tmp/flush-disk"
	#rexec ${i} "for disk in `ls -1 /dev/disks/naa*` | sed -e 's/:.*//') ; do echo $disk ; partedUtil mklabel $disk msdos ; done"
done
