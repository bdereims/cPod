#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=esx-comp-06
NAME=cpod-vio-esx-comp-06
IP=172.18.0.52
OVA=${BITS}/Nested_ESXi6.5d_Appliance_Template_v1.0.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:guestinfo.ssh=True \
--prop:guestinfo.createvmfs=False \
--prop:guestinfo.password=${PASSWORD} \
--prop:guestinfo.hostname=${HOSTNAME} \
--prop:guestinfo.ipaddress=${IP} \
--prop:guestinfo.netmask=${NETMASK} \
--prop:guestinfo.gateway=${GATEWAY} \
--prop:guestinfo.dns=${DNS} \
--prop:guestinfo.domain=${DOMAIN} \
--prop:guestinfo.ntp=${NTP} \
-ds=${DATASTORE} -n=${NAME} --network='${PORTGROUP}' \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

#rm ${MYSCRIPT}
