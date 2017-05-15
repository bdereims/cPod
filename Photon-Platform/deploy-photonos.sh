#!/bin/bash
#bdereims@vmware.com

###
### Deploy PhotonOS OVA 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

HOSTNAME=photon-2
NAME=photon-2
OVA=${BITS}/photon-custom-hw10-1.0-62c543d.ova
DATASTORE=Datastore
TARGET=esx-03

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
cd ${OVFDIR}
./ovftool --acceptAllEulas --noSSLVerify --skipManifestCheck \
--X:injectOvfEnv --overwrite --powerOffTarget --allowExtraConfig \
--X:apiVersion=5.5 --X:waitForIp --powerOn --diskMode=thin \
--prop:ip0=${IP} \
--prop:netmask0=${NETMASK} \
--prop:gateway=${GATEWAY} \
--prop:DNS=${DNS} \
--prop:ntp_servers=${NTP} \
--prop:admin_password=${PASSWORD} \
--prop:pcuser_password=${PASSWORD} \
"--datastore=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
