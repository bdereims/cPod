#!/bin/bash
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ./"${1}"

### Local vars ####

TENANT=Demo
PROJECT=demo-project

###################

photon target set -c https://${PCONTROLLER}:443 
photon target login --username administrator@esxcloud --password VMware1!

photon system status

TENANT_ID=`photon tenant list | grep ${TENANT} | cut -d' ' -f1`
photon tenant set ${TENANT} 

PROJECT_ID=`photon project list | grep ${PROJECT} | cut -d' ' -f1`
photon project set ${PROJECT}
