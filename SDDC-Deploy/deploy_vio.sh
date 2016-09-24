#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=oms
NAME=VIO
IP=192.168.1.39
OVA=${BITS}/VMware-OpenStack-3.0.0.0-4334264_OVF10.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --allowExtraConfig \
--prop:vami.domain.management-server=${DOMAIN} \
--prop:vami.ip0.management-server=${IP} \
--prop:vami.netmask0.management-server=${NETMASK} \
--prop:vami.gateway.management-server=${GATEWAY} \
--prop:vami.DNS.management-server=${DNS} \
--prop:vami.searchpath.management-server=${DOMAIN} \
--prop:ntpServer=${NTP} \
"--prop:viouser_passwd=${PASSWD}" \
--vService:"installation"="com.vmware.vim.vsm:extension_vservice" \
-ds=${DATASTORE} -n=${NAME} --network=${PORTGROUP} \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
