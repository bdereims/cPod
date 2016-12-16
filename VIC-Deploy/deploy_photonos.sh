#!/bin/bash -x
#bdereims@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=photonos
NAME=${HOSTNAME}
IP=10.66.0.99
OVA=${BITS}/photon-custom-hw11-1.0-13c08b6.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--noSSLVerify --skipManifestCheck --powerOn --diskMode=thin \
"-ds=${DATASTORE}" -n=${NAME} "--network=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

#rm ${MYSCRIPT}
