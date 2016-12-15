#!/bin/bash
#bdereims@vmware.com


#[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
#[ ! -f "${1}" ] && echo "error: file '${1}' does not exist" && exit 1

#. ./"${1}"

### Local vars ####

###################

photon target set -c https://10.66.0.20:443 
photon target login --username administrator@esxcloud --password VMware1!
photon system status
