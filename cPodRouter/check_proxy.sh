#/bin/bash
#bdereims@vmware.com

PROXYHOST=$(echo ${http_proxy} | sed -e 's/^.*\/\///' -e's/:.*$//')
ping -c 1 ${PROXYHOST} &> /dev/null && exit 0
unset http_proxy https_proxy
