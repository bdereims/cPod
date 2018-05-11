#!/bin/bash

. ./govc_env

DELLVSAN=$( govc datastore.info DELL-VSAN | grep Free | sed -e "s/^.*://" -e "s/GB//" -e "s/ //g" )
DELLVSAN=$( echo "${DELLVSAN}/1" | bc )
DELLVSAN=$( expr ${DELLVSAN} )

if [ ${DELLVSAN} -lt 4500 ]; then
	echo "No more space!"
	exit 1
fi

echo "Ok!"
exit 0
