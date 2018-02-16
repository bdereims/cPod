#!/bin/bash

NSX_MANAGER=nsx-t.cpod-gv.shwrfr.mooo.com
NSX_USER=admin
NSX_USER_PASSWD=VMware1!

nsx_call() {
	# $1 : REST Call 

        curl -k -b cookies.$$ -H "`grep X-XSRF-TOKEN headers.$$`" \
        https://${NSX_MANAGER}${1}
}

create_nsx_session() {
	curl -k -c cookies.$$ -D headers.$$ -X POST \
	-d "j_username=${NSX_USER}&j_password=${NSX_USER_PASSWD}" \
	https://${NSX_MANAGER}/api/session/create
}

delete_nsx_session() {
	nsx_call "/api/session/destroy"
	rm cookies.$$ headers.$$
}

clean_ip_pool() {
	echo "Delete IP Pool"

	nsx_call "/api/v1/pools/ip-pools/${1}/allocations" > aip.lst
	for AIP in $( cat aip.lst | jq '.["results"] | .[] | .allocation_id' )
	do
		echo "{ \"allocation_id\": ${AIP} }" > aip.$$
		curl -k -b cookies.$$ -H "`grep X-XSRF-TOKEN headers.$$`" \
		-X POST -d @aip.$$ \
		-H 'Content-Type: application/json;charset=UTF-8' \
		-i https://${NSX_MANAGER}/api/v1/pools/ip-pools/${1}?action=RELEASE
	done

	curl -k -b cookies.$$ -H "`grep X-XSRF-TOKEN headers.$$`" \
	-X DELETE \
	-H 'Content-Type: application/json;charset=UTF-8' \
	-i https://${NSX_MANAGER}/api/v1/pools/ip-pools/${1}

	rm aip.lst 
}

main() {
	echo "Cleaning Up NSX-T"
	create_nsx_session

	clean_ip_pool "c7020af2-9671-45c3-af65-fded29ae431d"

	delete_nsx_session
}

main
