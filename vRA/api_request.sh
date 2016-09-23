#/bin/sh
#bdereims@vmware.com

source api_env.sh
source api_token.sh

curl --insecure -H "application/json" -H "Authorization: $AUTH" \
https://$VRA/catalog-service/api/consumer/requests \
| python -m json.tool
