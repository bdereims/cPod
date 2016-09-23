#/bin/sh
#bdereims@vmware.com

source api_env.sh
source api_token.sh

curl --insecure -H "Accept:application/json" -H "Authorization: $AUTH" \
--data @/tmp/owncloud.json -H "Content-Type:application/json" \
https://vra.cpod.net/catalog-service/api/consumer/entitledCatalogItems/04926753-dbd0-411e-8080-ce7a5f10d568/requests \
| python -m json.tool
