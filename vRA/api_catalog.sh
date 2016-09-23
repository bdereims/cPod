#/bin/sh
#bdereims@vmware.com

source api_env.sh
source api_token.sh

curl --insecure -H "Accept:text/json" -H "Authorization: $AUTH" \
https://$VRA/catalog-service/api/consumer/entitledCatalogItemViews \
| python -m json.tool
