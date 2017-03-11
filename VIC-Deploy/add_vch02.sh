#!/bin/bash -x
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

./vic-machine-linux create --target 'vcsa.brmc.local/DC01' --user 'administrator@vsphere.local' \
--password 'VMware1!' --compute-resource 'CLCOMP02' --name 'VCH02' \
--bridge-network "vxw-dvs-70-virtualwire-13-sid-5009-VCH02-Bridge" --management-network "vxw-dvs-70-virtualwire-37-sid-5027-VCH02" \
--public-network "vxw-dvs-70-virtualwire-37-sid-5027-VCH02" --client-network "vxw-dvs-70-virtualwire-37-sid-5027-VCH02" \
--thumbprint "2B:6C:C9:83:FD:DD:25:F7:8B:D1:1A:FB:49:00:3F:42:44:AE:CE:8C" \
--image-store 'Datastore' \
--no-tls \
--dns-server=172.16.60.10 \
--debug 1 
#--force --timeout 10m0s
#--image-store "dsVSAN-COMP-02"
#--dns-server=10.66.0.15 \
#--management-network-gateway 10.66.0.1/24 --management-network-ip 10.66.0.31 \
#--public-network-gateway 10.66.0.1/24 --public-network-ip 10.66.0.32 \
#--thumbprint 57:21:1B:AD:74:DF:44:06:8B:CE:2E:7E:6E:E3:13:CF:D9:C4:E8:42 \
