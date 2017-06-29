#!/bin/bash
#bdereims@vmware.com

. ./env

PS_SCRIPT=mod_portgroup.ps1

mkdir -p /tmp/scripts
cp ${COMPUTE_DIR}/${PS_SCRIPT} /tmp/scripts/$$.ps1
docker run --rm -it -v /tmp/scripts:/tmp/scripts vmware/powerclicore:ubuntu14.04 powershell /tmp/scripts/$$.ps1
