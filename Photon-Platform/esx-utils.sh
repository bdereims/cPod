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
