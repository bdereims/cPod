#!/bin/sh
# Copyright 2017, bdereims@vmware.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Must install jq: https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 
#usage: destroy_vm.sh <name-of-vm>

export REFRESHRATE=20
export USERNAME=<username@tenant.local in vRA, ex. administrator@vsphere.local>
export PASSWORD=<user password>
export TENANT=<tenant where the blueprint is, ex. vsphere.local>
export VRA=<vRA appliance FQDN, ex. vra.cpod.net>
export BLUEPRINT=<Blueprint Name, ex. CentOS>
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
