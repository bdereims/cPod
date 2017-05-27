#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

###################

mkdir -p /tmp/scripts
cp prep-vcsa.ps1 /tmp/scripts
docker run --rm -it -v /tmp/scripts:/tmp/scripts --entrypoint='/usr/bin/powershell' vmware/powerclicore /tmp/scripts/prep-vcsa.ps1
