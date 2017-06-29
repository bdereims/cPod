#!/bin/bash
#bdereims@vmware.com

. ./env

[ "$1" == "" ] && echo "usage: $0 <name_of_cpod>" && exit 1 

mutex() {
	[ -f lock ] && echo "A cPod creation is running, please launch later." && exit 1
	touch lock
}

release_mutex() {
	rm -fr lock
}

exit_gate() {
	release_mutex
	exit $1 
}

main() {
	echo "=== Deleting to deploy a new cPod called '$1'."
	mutex

	CPOD_NAME="cpod-$1"
	#${NETWORK_DIR}/delete_logicalswitch.sh ${NSX_TRANSPORTZONE} ${CPOD_NAME}

	echo "=== Deletion is finished."
	exit_gate 0
}

main $1 $2
