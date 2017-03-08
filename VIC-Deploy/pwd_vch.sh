#!/bin/bash -x
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

THUMBPRINT=`openssl s_client -connect ${VCSA}:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin | sed -e 's/^.*=//'`

###################

cd ${VIC_DIR}

./vic-machine-linux debug --target ${TARGET} --user ${ADMIN} \
--password ${VC_PASSWORD} --name VCH02 --enable-ssh --rootpw ${PASSWORD} \
--compute-resource CLCOMP02 \
--thumbprint ${THUMBPRINT} 
