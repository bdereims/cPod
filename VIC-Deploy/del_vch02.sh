#!/bin/bash -x
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

cd ${VIC_DIR}

./vic-machine-linux delete --target vcsa.brmc.local/DC01 --force \
--user administrator@vsphere.local --password VMware1! \
--compute-resource CLCOMP02 --name VCH02 \
--force
#--thumbprint 57:21:1B:AD:74:DF:44:06:8B:CE:2E:7E:6E:E3:13:CF:D9:C4:E8:42
