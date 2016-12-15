#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=photon-vsan
NAME=photon-vsan
IP=10.66.0.18
OVA=${BITS}/vsan-1.1.0-5de1cb7.ova
LIGHTWAVE=10.66.0.21
LWDOMAIN=esxcloud
LWADMINGROUP=VSANAdmins

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --noSSLVerify --skipManifestCheck \
--X:injectOvfEnv --overwrite --powerOffTarget --allowExtraConfig \
--X:apiVersion=5.5 --powerOn --diskMode=thin \
--prop:gateway=${GATEWAY} \
--prop:ip0=${IP} \
--prop:hostname=${HOSTNAME} \
--prop:netmask0=${NETMASK} \
--prop:root_password=${PASSWORD} \
--prop:lw_hostname=${LIGHTWAVE} \
--prop:lw_password=${PASSWORD} \
--prop:lw_domain=${LWDOMAIN} \
--prop:lw_admingroup=${LWADMINGRP} \
"--datastore=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
