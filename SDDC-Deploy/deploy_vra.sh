#!/bin/sh
#bdereims@vmware.com


### Local vars ####

HOSTNAME=vra
NAME=vRA
IP=192.168.1.42
OVA=${BITS}/VMware-vR-Appliance-7.0.1.150-3622989_OVF10.ova

###################

export MYSCRIPT=/tmp/$$

if [ "${1}" == "" ]; then
	echo "usage: deploy_xxx.sh deploy_env"
	exit 1
fi

. ./${1}

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
vi://${ADMIN}:${PASSWORD}@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
