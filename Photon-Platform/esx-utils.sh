#!/bin/bash -x
#bdereims@vmware.com

###
### Functions to interact with ESX
###

### Remote exec cmd on ESX
### $1 : ESX @IP
### $2 : cmd to execute 
function rexec {
	STATUS="\e[91mFailed\e[0m"
	echo -e "Exec on ${1} : \e[2m${2}\e[0m with ${ADMIN}"
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	${ADMIN}@${1} $2
	[ ${?} -eq 0 ] && STATUS="\e[32mOk\e[0m" 	
	echo -e "Exec status : ${STATUS}"
}

### Poweroff ESX
### $1 : ESX @IP
function rpoweroff {
        STATUS="\e[91mFailed\e[0m"
        echo -e "Poweroff ${1}"
        sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        ${ADMIN}@${1} "poweroff" 
        [ ${?} -eq 0 ] && STATUS="\e[32mOk\e[0m"
        echo -e "Exec status : ${STATUS}"
}

### Copy file 
### $1 : ESX @IP
### $2 : Source and local file
### $3 : Target on remote
function rscp {
	STATUS="\e[91mFailed\e[0m"
	echo -e "Copy ${2} on ${1} as \e[2m${3}\e[0m with ${ADMIN}"
	sshpass -p ${PASSWORD} scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	${2} ${ADMIN}@${1}:${3}
        [ ${?} -eq 0 ] && STATUS="\e[32mOk\e[0m"
        echo -e "Copy status : ${STATUS}"
}
