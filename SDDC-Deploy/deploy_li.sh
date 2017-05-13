#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=li
NAME=LI
IP=172.18.0.92
OVA=${BITS}/VMware-vRealize-Log-Insight-4.3.0-5084751.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:vami.DNS.VMware_vCenter_Log_Insight=${DNS} \
--prop:vami.domain.VMware_vCenter_Log_Insight=${DOMAIN} \
--prop:vami.gateway.VMware_vCenter_Log_Insight=${GATEWAY} \
--prop:vami.hostname.VMware_vCenter_Log_Insight=${HOSTNAME} \
--prop:vami.ip0.VMware_vCenter_Log_Insight=${IP} \
--prop:vami.netmask0.VMware_vCenter_Log_Insight=${NETMASK} \
--prop:vami.searchpath.VMware_vCenter_Log_Insight=${DOMAIN} \
--prop:vm.rootpw=${PASSWORD} \
-ds=${DATASTORE} -n=${NAME} --network=${PORTGROUP} \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
