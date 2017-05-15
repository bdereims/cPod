#!/bin/bash
#bdereims@vmware.com

###
### Deploy Photon Controller OVA 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

HOSTNAME=photon-installer
NAME=photon-installer
OVA=${BITS}/installer-ova-nv-1.2.1-77a6d82.ova
IP=172.18.2.19
DATASTORE=Datastore

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
cd ${OVFDIR}
./ovftool --acceptAllEulas --noSSLVerify --skipManifestCheck \
--X:injectOvfEnv --overwrite --powerOffTarget --allowExtraConfig \
--X:apiVersion=5.5 --X:waitForIp --powerOn --diskMode=thin \
--prop:ip0=${IP} \
--prop:netmask0=${NETMASK} \
--prop:gateway0=${GATEWAY} \
--prop:DNS=${DNS} \
--prop:ntp_servers=${NTP} \
"--datastore=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
