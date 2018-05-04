#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

HOSTS=/etc/hosts

main() {
	echo "=== Preparing cPod called '$1'."

	SHELL_SCRIPT=prep_and_add_esx.sh

	SCRIPT_DIR=/tmp/scripts
	SCRIPT=/tmp/scripts/$$

	mkdir -p ${SCRIPT_DIR} 
	cp ${COMPUTE_DIR}/${SHELL_SCRIPT} ${SCRIPT}
	sed -i -e "s/###ROOT_PASSWD###/${ROOT_PASSWD}/" ${SCRIPT}

	CPOD_NAME="cpod-$1"
	CPOD_NAME_LOWER=$( echo ${CPOD_NAME} | tr '[:upper:]' '[:lower:]' )
	#IP=$( cat ${HOSTS} | grep ${CPOD_NAME_LOWER} | cut -f1 )

        #STATUS=1
        #while [ ${STATUS} -gt 0 ]
        #do
        #        echo "Waiting for cPodRouter of ${CPOD_NAME_LOWER}..."
        #        STATUS=$( ping -c 1 ${CPOD_NAME_LOWER} 2>&1 > /dev/null ; echo $? )
        #        STATUS=$(expr $STATUS)
        #done
	./compute/wait_ip.sh ${CPOD_NAME_LOWER} 

	sshpass -p ${ROOT_PASSWD} scp ~/.ssh/id_rsa.pub root@${CPOD_NAME_LOWER}:/root/.ssh/authorized_keys
	scp -o StrictHostKeyChecking=no ${SCRIPT} root@${CPOD_NAME_LOWER}:./${SHELL_SCRIPT} 
	ssh -o StrictHostKeyChecking=no root@${CPOD_NAME_LOWER} "./${SHELL_SCRIPT}"

	rm ${SCRIPT}
}

main $1
