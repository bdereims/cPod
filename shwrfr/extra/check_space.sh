#!/bin/bash

. ./govc_env
. ./env

CLUSTER=$( echo $CLUSTER | tr '[:lower:]' '[:upper:]' )

DELLVSAN=$( govc datastore.info ${CLUSTER}-VSAN | grep Free | sed -e "s/^.*://" -e "s/GB//" -e "s/ //g" )
DELLVSAN=$( echo "${DELLVSAN}/1" | bc )
DELLVSAN=$( expr ${DELLVSAN} )

if [ ${DELLVSAN} -lt 10000 ]; then
	echo "No more space!"
	exit 1
fi

echo "Ok!"
exit 0
