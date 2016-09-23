#!/bin/sh
#bdereims@vmware.com

source api_env.sh

DATA='{"username":"'$USERNAME'","password":"'$PASSWORD'","tenant":"'$TENANT'"}'

TOKEN=$(curl --insecure --request POST -H "Accept:application/json" -H "Content-Type:application/json" \
--data $DATA https://$VRA/identity/api/tokens) 

AUTH=$(echo $TOKEN | sed -e 's/^.*id":"//' -e 's/=.*$/=/')
AUTH="Bearer $AUTH"

#curl --insecure --request POST -H "Accept:txt/xml" -H "'"$AUTH"'" \
#https://$VRA/catalog-service/api/consumer/entitledCatalogItems

#curl --insecure -H "Accept:text/xml" -H "Authorization: $AUTH" https://vra.cpod.net/catalog-service/api/consumer/entitledCatalogItemViews
