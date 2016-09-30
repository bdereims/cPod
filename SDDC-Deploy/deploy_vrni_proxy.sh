#!/bin/bash
#bdereims@vmware.com

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

HOSTNAME=orange-vrni-proxy
NAME=orange-vrni-proxy
IP=10.66.0.30
OVA=${BITS}/VMware_vRealize_Network_Insight_3.0.0-1469457715_proxy.ova

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
ovftool --acceptAllEulas --X:injectOvfEnv --allowExtraConfig \
--prop:Proxy_Shared_Secret="I7/W1rFiBWaRWrA/H20+PgckKZct9qgg2wqKkdAs81JroQ0C+hiyHCtwi91PWRqdrt81TfBZHeMk1BQZ3W1/UulLgoGtZEK49lz1BvtIh9uZ0g095Gk2IJCjfVjH3NeR5PVuTf1bZ8wUzznKMT9kB9gY3GekEjIruWqvJ5CeQsw=" \
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
