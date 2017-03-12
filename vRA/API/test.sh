#!/bin/sh
#bdereims@vmware.com

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

curl -s --insecure -H "application/json" -H "Authorization: $AUTH" \
https://$VRA/catalog-service/api/consumer/requests/a4d0b0e7-b389-4e17-a5ab-c3d28b3682a9 \
| python -m json.tool 
