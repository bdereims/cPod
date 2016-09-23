#/bin/sh
#bdereims@vmware.com

source api_env.sh
source api_token.sh

curl --insecure -H "application/json" -H "Authorization: $AUTH" \
https://vra.cpod.net/catalog-service/api/consumer/entitledCatalogItems/04926753-dbd0-411e-8080-ce7a5f10d568/requests/template \
| python -m json.tool > /tmp/owncloud.json
