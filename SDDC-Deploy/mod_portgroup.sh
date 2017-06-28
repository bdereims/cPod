#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} portgroup_name" && exit 1

### Local vars ####

###################



mkdir -p /tmp/scripts
cp ${PS_SCRIPT} /tmp/scriptss
docker run --rm -it -v /tmp/scripts:/tmp/scripts vmware/powerclicore:ubuntu14.04 powershell /tmp/scripts/${PS_SCRIPT}.ps1
