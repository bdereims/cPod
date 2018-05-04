#!/bin/bash 
#bdereims@vmware.com

. ./env

[ "${1}" == "" ] && echo "usage: ${0} <deploy_env or cPod Name>" && exit 1


if [ -f "${1}" ]; then
	. ./${COMPUTE_DIR}/"${1}"
else
	SUBNET=$( ./${COMPUTE_DIR}/cpod_ip.sh ${1} )

	[ $? -ne 0 ] && echo "error: file or env '${1}' does not exist" && exit 1

	CPOD=${1}
	. ./${COMPUTE_DIR}/cpod-xxx_env
fi

VCSA_CONF_FILE="/tmp/${$}-vcsa-67.json"

### update vCSA vars ####

HOSTNAME=${HOSTNAME_VCSA}
NAME=${NAME_VCSA}
IP=${IP_VCSA}
OVA=${BITS}/VMware-VCSA-all-6.7.0-8217866.iso
TARGET=${TARGET_VCSA}
DATASTORE=${DATASTORE_VCSA}
PORTGROUP=${PORTGROUP_VCSA}

###################

STATUS=$( ping -c 1 ${IP} 2>&1 > /dev/null ; echo $? )
STATUS=$(expr $STATUS)
if [ ${STATUS} == 0 ]; then
	echo "Error: Something have the same IP."
	./extra/post_slack.sh ":wow: Are you sure that VCSA is not already deployed in ${1}. Something have the same @IP."
	exit 1
fi

umount /mnt
mount -o loop $OVA /mnt

SEDCMD="s/###PASSWORD###/${PASSWORD}/;s!###TARGET###!${TARGET}!;s/###PORTGROUP###/${PORTGROUP}/;s/###DATASTORE###/${DATASTORE}/;s/###IP###/${IP}/;s/###DNS###/${DNS}/;s/###GATEWAY###/${GATEWAY}/;s/###HOSTNAME###/${HOSTNAME}/;s/###NAME###/${NAME}/;s/###PSC###/${HOSTNAME_PSC}/;s/###DOMAIN###/${DOMAIN}/"
cat ${COMPUTE_DIR}/vcsa-67.json | sed "${SEDCMD}"  > ${VCSA_CONF_FILE} 

./extra/post_slack.sh "Deploying a new VCSA for *${DOMAIN}*. We're working for you, it takes times. Stay tuned..."

pushd /mnt/vcsa-cli-installer/lin64
ROOT="/mnt/vcsa-cli-installer/lin64"
export LD_LIBRARY_PATH=$ROOT:$ROOT/openssl-1.0.2l/lib/:$ROOT/libffi-6.0.4/lib/
./vcsa-deploy.bin install -t --no-ssl-certificate-verification --skip-ovftool-verification --accept-eula --acknowledge-ceip ${VCSA_CONF_FILE} 
popd

sleep 60 

CPOD="${1}"
CPOD_LOWER=$( echo ${1} | tr '[:upper:]' '[:lower:]' )
NUMESX=$( ssh root@cpod-${CPOD_LOWER} "grep esx /etc/hosts | wc -l" )
./compute/prep_vcsa.sh ${CPOD} ${NUMESX}

rm ${VCSA_CONF_FILE}

./extra/post_slack.sh ":thumbsup: VCSA for <https://vcsa.${DOMAIN}|${DOMAIN}> seems ready!"
