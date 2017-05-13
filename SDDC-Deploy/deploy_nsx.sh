#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=nsx
NAME=NSX
IP=172.18.0.98
OVA=${BITS}/VMware-NSX-Manager-6.3.1-5124716.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:vsm_cli_passwd_0=${PASSWORD} \
--prop:vsm_cli_en_passwd_0=${PASSWORD} \
--prop:vsm_hostname=${HOSTNAME} \
--prop:vsm_ip_0=${IP} \
--prop:vsm_netmask_0=${NETMASK} \
--prop:vsm_gateway_0=${GATEWAY} \
--prop:vsm_dns1_0=${DNS} \
--prop:vsm_domain_0=${DOMAIN} \
--prop:vsm_ntp_0=${NTP} \
--prop:vsm_isSSHEnabled=True \
-ds=${DATASTORE} -n=${NAME} --network='${PORTGROUP}' \
${OVA} \
vi://${ADMIN}:'${VC_PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

#rm ${MYSCRIPT}
