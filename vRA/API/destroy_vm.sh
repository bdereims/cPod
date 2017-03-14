#!/bin/sh
#bdereims@vmware.com
#Must install jq: https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 
#usage: destroy_vm.sh <name-of-vm>

export REFRESHRATE=20
export USERNAME=erable@brmc.local
export PASSWORD=c@perabl3
export TENANT=vsphere.local
export VRA=vra.brmc.local
export BLUEPRINT=Erable
export BPJSON=/tmp/$BLUEPRINT-$$.json

DATA='{"username":"'$USERNAME'","password":"'$PASSWORD'","tenant":"'$TENANT'"}'

#Build Token 
TOKEN=$(curl -s --insecure --request POST -H "Accept:application/json" -H "Content-Type:application/json" \
--data $DATA https://$VRA/identity/api/tokens) 

AUTH=$(echo $TOKEN | sed -e 's/^.*id":"//' -e 's/".*$//')
AUTH="Bearer $AUTH"

#Query Blueprint ID
BPID=$(curl -s --insecure -H "Accept:text/json" -H "Authorization: $AUTH" https://$VRA/catalog-service/api/consumer/resources?%24filter=name+eq+%27${1}%27 | python -m json.tool | jq '. | .["content"] | .[0] | {name: .name, parentResourceRef: .parentResourceRef.id} | {parentResourceRef}' | head -2 | tail -1  | sed -e 's/.*": "//' -e 's/".*$//')

#Does the VM exist?
if [ "${BPID}" == "  " ]
then
	echo "VM ${1} not found!"
	exit 1 
fi

#Query Destroy Action ID for the Parent Blueprint
DESTROYID=$(curl -s --insecure -H "Accept:text/json" -H "Authorization: $AUTH" https://$VRA/catalog-service/api/consumer/resources/${BPID}/actions | python -m json.tool | jq '.content[] | {name: .name, id: .id} | select(.name == "Destroy") | .id' | sed -e 's/"//g')

#Request JSON Template for Destroying
curl -s --insecure -H "application/json" -H "Authorization: $AUTH" \
https://$VRA/catalog-service/api/consumer/resources/${BPID}/actions/${DESTROYID}/requests/template \
| python -m json.tool > $BPJSON

#Request the Destroy action
curl -s --insecure -H "Accept:application/json" -H "Authorization: $AUTH" --data @$BPJSON -H "Content-Type:application/json" https://$VRA/catalog-service/api/consumer/resources/${BPID}/actions/${DESTROYID}/requests

#CleanUp
rm $BPJSON
