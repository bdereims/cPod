#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=photon-installer
NAME=photon-installer
IP=10.66.0.17
OVA=${BITS}/installer-vm-1.1.0-5de1cb7.ova 

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:DNS=${DNS} \
--prop:ntp_servers=${NTP} \
--prop:gateway=${GATEWAY} \
--prop:ip0=${IP} \
--prop:netmask0=${NETMASK} \
--prop:admin_password=${PASSWORD} \
--prop:pcuser_password=${PASSWORD} \
"--datastore=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
--powerOn --diskMode=thin \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
