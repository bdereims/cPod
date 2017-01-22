#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=photonos
NAME=photonos
IP=172.16.60.99
OVA=${BITS}/photon-custom-hw10-1.0-13c08b6.ova

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
