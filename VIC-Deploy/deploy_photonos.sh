#!/bin/bash
#bdereims@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=photon
NAME=${HOSTNAME}
OVA=${BITS}/photon-custom-hw10-1.0-62c543d.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--noSSLVerify --skipManifestCheck --powerOn --diskMode=thin \
"-ds=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}/host/${CLUSTER}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
