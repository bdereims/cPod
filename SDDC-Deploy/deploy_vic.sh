#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=vic
NAME=VIC
IP=172.18.1.26
OVA=${BITS}/vic-v1.1.0-bf760ea2.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:appliance.root_pwd=${PASSWORD} \
--prop:registry.admin_password=${PASSWORD} \
--prop:registry.db_password=${PASSWORD} \
--prop:network.ip0=${IP} \
--prop:network.netmask0=${NETMASK} \
--prop:network.gateway=${GATEWAY} \
--prop:network.DNS=${DNS} \
--prop:network.searchpath=${DOMAIN} \
--prop:network.fqdn=${HOSTNAME}.${DOMAIN} \
-ds=${DATASTORE} -n=${NAME} --network='${PORTGROUP}' \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

#rm ${MYSCRIPT}
