#!/bin/bash 
#bdereims@vmware.com

. ./env

[ "${1}" == "" ] && echo "usage: ${0} <deploy_env or cPod Name> <num_of_esx>" && exit 1


if [ -f "${1}" ]; then
	. ./${COMPUTE_DIR}/"${1}"
else
	SUBNET=$( ./${COMPUTE_DIR}/cpod_ip.sh ${1} )

	[ $? -ne 0 ] && echo "error: file or env '${1}' does not exist" && exit 1

	CPOD=${1}
	. ./${COMPUTE_DIR}/cpod-xxx_env
fi

PSC_CONF_FILE="/tmp/${$}-psc-65.json"
VCSA_CONF_FILE="/tmp/${$}-vcsa-65.json"

### PSC vars ####

HOSTNAME=${HOSTNAME_PSC}
NAME=${NAME_PSC}
IP=${IP_PSC}
OVA=${OVA_VCSA}
TARGET=${TARGET_VCSA}
DATASTORE=${DATASTORE_VCSA}
PORTGROUP=${PORTGROUP_VCSA}

###################

#umount /mnt
#mount -o loop $OVA /mnt

SEDCMD="s/###PASSWORD###/${PASSWORD}/;s!###TARGET###!${TARGET}!;s/###PORTGROUP###/${PORTGROUP}/;s/###DATASTORE###/${DATASTORE}/;s/###IP###/${IP}/;s/###DNS###/${DNS}/;s/###GATEWAY###/${GATEWAY}/;s/###HOSTNAME###/${HOSTNAME}/;s/###NAME###/${NAME}/;s/###SITE###/${SITE}/;s/###DOMAIN###/${DOMAIN}/"
cat ${COMPUTE_DIR}/psc-65.json | sed "${SEDCMD}"  > ${PSC_CONF_FILE} 

./extra/post_slack.sh "Deploying a new PSC for ${DOMAIN}"

pushd /mnt/vcsa-cli-installer/lin64
./vcsa-deploy install --no-esx-ssl-verify --accept-eula --acknowledge-ceip ${PSC_CONF_FILE} 
popd

sleep 60

### update vCSA vars ####

HOSTNAME=${HOSTNAME_VCSA}
NAME=${NAME_VCSA}
IP=${IP_VCSA}

###################

SEDCMD="s/###PASSWORD###/${PASSWORD}/;s!###TARGET###!${TARGET}!;s/###PORTGROUP###/${PORTGROUP}/;s/###DATASTORE###/${DATASTORE}/;s/###IP###/${IP}/;s/###DNS###/${DNS}/;s/###GATEWAY###/${GATEWAY}/;s/###HOSTNAME###/${HOSTNAME}/;s/###NAME###/${NAME}/;s/###PSC###/${HOSTNAME_PSC}/;s/###DOMAIN###/${DOMAIN}/"
cat ${COMPUTE_DIR}/vcsa-65.json | sed "${SEDCMD}"  > ${VCSA_CONF_FILE} 

./extra/post_slack.sh "Deploying a new VCSA for ${DOMAIN}"

pushd /mnt/vcsa-cli-installer/lin64
./vcsa-deploy install --no-esx-ssl-verify --accept-eula --acknowledge-ceip ${VCSA_CONF_FILE} 
popd

sleep 60 

NUMESX=$( ssh root@cpod-devops "grep esx /etc/hosts | wc -l" )
./compute/prep_vcsa.sh ${CPOD} ${NUMESX}

rm ${PSC_CONF_FILE}
rm ${VCSA_CONF_FILE}

./extra/post_slack.sh "VCSA for ${DOMAIN} seems ready!"
