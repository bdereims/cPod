#!/bin/sh
#bdereims@vmware.com

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
BPID=$(curl -s --insecure -H "Accept:text/json" -H "Authorization: $AUTH" https://$VRA/catalog-service/api/consumer/entitledCatalogItemViews?%24filter=name+eq+%27${BLUEPRINT}%27 | python -m json.tool | grep "catalogItemId" | sed -e 's/.*": "//' -e 's/".*$//')

#Create JSON template
curl -s --insecure -H "application/json" -H "Authorization: $AUTH" \
https://$VRA/catalog-service/api/consumer/entitledCatalogItems/$BPID/requests/template \
| python -m json.tool > $BPJSON

#Do the request
REQUESTID=$(curl -s --insecure -H "Accept:application/json" -H "Authorization: $AUTH" --data @$BPJSON -H "Content-Type:application/json" https://$VRA/catalog-service/api/consumer/entitledCatalogItems/$BPID/requests | python -m json.tool | grep "id" | sed -e 's/.*": "//' -e 's/".*$//')

START=$(date +%s.%N)

#Wait until VM is sucessfully deployed

#String -> Array
ID=(${REQUESTID// / })

echo "Refresh Rate: ${REFRESHRATE}s"
while true; do
	STATUS=$(curl -s --insecure -H "application/json" -H "Authorization: $AUTH" https://$VRA/catalog-service/api/consumer/requests/${ID[2]} | python -m json.tool | grep "stateName" | sed -e 's/.*": "//' -e 's/".*$//')
	if [ "$STATUS" == "Successful" ] || [ "$STATUS" == "Failed" ]
	then
		break
	fi
	END=$(date +%s.%N)
	DIFF=$(echo "$END - $START" | bc)
	echo -en "\rDuration: ${DIFF}s - Current status: $STATUS"
	sleep $REFRESHRATE 
done

#Deployment is done
if [ "$STATUS" == "Successful" ]
then
	echo -e "\nDeployment complete in ${DIFF}s"

	#Get Name and IP
	curl -s --insecure -H "application/json" -H "Authorization: $AUTH" https://$VRA/catalog-service/api/consumer/requests/${ID[2]}/resourceViews | python -m json.tool > ${BPJSON}-result
	echo -e "\nHostname:" ; cat ${BPJSON}-result | grep "MachineName" | sed -e 's/.*": "//' -e 's/".*$//'
	echo -e "\nIP Address:" ; cat ${BPJSON}-result | grep "ip_address" | sed -e 's/.*": "//' -e 's/".*$//'
else
	echo -e "\nDeployment failed after ${DIFF}s"
fi


#CleanUp
rm $BPJSON
rm $BPJSON-result
