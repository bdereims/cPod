#/bin/bash

PROXYHOST=$(echo ${http_proxy} | sed -e 's/^.*\/\///' -e's/:.*$//')

ping -c 1 ${PROXYHOST} 2>&1 > /dev/null
if [ $? == "1" ]
then
	echo "no proxy"
	unset http_proxy https_proxy
fi
