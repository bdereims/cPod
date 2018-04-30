	STATUS=1 
	while [ ${STATUS} -gt 0 ]
        do
                echo "Waiting for cPodRouter of ${CPOD_NAME_LOWER}"
		STATUS=$( ping -c 1 172.16.0.99 2>&1 > /dev/null ; echo $? )
		STATUS=$(expr $STATUS)
        done
