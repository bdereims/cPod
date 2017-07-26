#!/bin/bash
#bdereims@vmware

# $1 : VCSA FQDN

export THUMBPRINT=`openssl s_client -connect ${1}:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin | sed -e 's/^.*=//'`

echo ${THUMBPRINT}
