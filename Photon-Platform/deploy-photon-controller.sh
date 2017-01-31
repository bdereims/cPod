#!/bin/bash
#bdereims@vmware.com

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}

### Local vars ####

HOSTNAME=photon-controller
NAME=photon-controller
IP=${PCIP}
OVA=${BITS}/installer-vm-1.1.0-5de1cb7.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
cd ${OVFDIR}
./ovftool --acceptAllEulas --noSSLVerify --skipManifestCheck \
--X:injectOvfEnv --overwrite --powerOffTarget --allowExtraConfig \
--X:apiVersion=5.5 --powerOn --diskMode=thin \
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
