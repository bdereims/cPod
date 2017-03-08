#!/bin/bash -x
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

./vic-machine-linux create --target vcsa.brmc.local/DC01 --user 'administrator@vsphere.local' \
--password 'VMware1!' --compute-resource CLCOMP01 --image-store dsVSAN-COMP-01 --name VCH01 --no-tlsverify \
--bridge-network "vxw-dvs-67-virtualwire-11-sid-5008-VCH01-Bridge" --management-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" \
--public-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" --client-network "vxw-dvs-67-virtualwire-38-sid-5028-VCH01" \
--force 
#--dns-server=10.66.0.15 \
#--management-network-gateway 10.66.0.1/24 --management-network-ip 10.66.0.31 \
#--public-network-gateway 10.66.0.1/24 --public-network-ip 10.66.0.32 \
#--thumbprint 57:21:1B:AD:74:DF:44:06:8B:CE:2E:7E:6E:E3:13:CF:D9:C4:E8:42 \
