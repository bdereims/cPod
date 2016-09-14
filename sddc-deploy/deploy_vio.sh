#!/bin/sh

. ./deploy_env.sh

ovftool --acceptAllEulas --allowExtraConfig \
--prop:vami.domain.management-server=${DOMAIN} \
--prop:vami.ip0.management-server=192.168.1.39 \
--prop:vami.netmask0.management-server=${NETMASK} \
--prop:vami.gateway.management-server=${GATEWAY} \
--prop:vami.DNS.management-server=${DNS} \
--prop:vami.searchpath.management-server=${DOMAIN} \
--prop:ntpServer=${NTP} \
"--prop:viouser_passwd=${PASSWD}" \
--vService:"installation"="com.vmware.vim.vsm:extension_vservice" \
-ds=${DATASTORE} -n=VIO --network=${PORTGROUP} ./VMware-OpenStack-3.0.0.0-4334264_OVF10.ova \
vi://administrator%40vsphere.local:VMware1!@vcenter.cpod.net/Datacenter/host/AdminCluster/esx02.cpod.net/
