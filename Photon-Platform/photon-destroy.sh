#!/bin/bash
#bdereims@vmware.com

CONFDIR=./conf.d

[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1
[ ! -f "${CONFDIR}/${1}" ] && echo "error: file '${1}' does not exist" && exit 1

. ${CONFDIR}/${1}

### Local vars ####

###################

photon target set http://${PCIP}:9000
photon system destroy 
