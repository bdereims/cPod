#!/bin/bash
#bdereims@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=${HOSTNAME_VRA}
NAME=${NAME_VRA}
IP=${IP_VRA}
OVA=${OVA_VRA}

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:va-ssh-enabled=True \
--prop:vami.DNS.VMware_vRealize_Appliance=${DNS} \
--prop:vami.domain.VMware_vRealize_Appliance=${DOMAIN} \
--prop:vami.gateway.VMware_vRealize_Appliance=${GATEWAY} \
--prop:vami.hostname=${HOSTNAME} \
--prop:vami.ip0.VMware_vRealize_Appliance=${IP} \
--prop:vami.netmask0.VMware_vRealize_Appliance=${NETMASK} \
--prop:vami.searchpath.VMware_vRealize_Appliance=${DOMAIN} \
--prop:varoot-password=${PASSWORD} \
-ds=${DATASTORE} -n=${NAME} --network=${PORTGROUP} \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
