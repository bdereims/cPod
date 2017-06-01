#!/bin/bash -x
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=vcsa.cpod-vr.shwrfr.mooo.com
NAME=VCSA
IP=172.18.1.30
OVA=${BITS}/VMware-VCSA-all-6.5.0-5318154.iso
TARGET=172.18.3.11
DATASTORE=Temp

###################

SEDCMD="s/###PASSWORD###/${PASSWORD}/;s!###TARGET###!${TARGET}!;s/###PORTGROUP###/${PORTGROUP}/;s/###DATASTORE###/${DATASTORE}/;s/###IP###/${IP}/;s/###DNS###/${DNS}/;s/###GATEWAY###/${GATEWAY}/;s/###HOSTNAME###/${HOSTNAME}/;s/###NAME###/${NAME}/"
cat vcsa-65.json | sed "${SEDCMD}"  > /tmp/vcsa-65.json

mount -o loop $OVA /mnt
cd /mnt/vcsa-cli-installer/lin64
./vcsa-deploy install --no-esx-ssl-verify --accept-eula --acknowledge-ceip /tmp/vcsa-65.json
