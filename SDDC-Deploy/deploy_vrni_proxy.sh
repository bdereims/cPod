#!/bin/bash
#bdereims@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=vrni-proxy
NAME=vrni-proxy
IP=172.16.60.26
OVA=${BITS}/VMWare-vRealize-Networking-insight-3.2.0.1480511973-proxy.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:Proxy_Shared_Secret="" \
--prop:DNS=${DNS} \
--prop:IP_Address=${IP} \
--prop:Netmask=${NETMASK} \
--prop:Default_Gateway=${GATEWAY} \
--prop:Domain_Search=${DOMAIN} \
--prop:NTP=${NTP} \
--prop:Rsyslog_IP=${SYSLOG} \
--prop:Log_Push=False \
-ds=${DATASTORE} -n=${NAME} --network=${PORTGROUP} \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
