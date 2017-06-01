#!/bin/bash -x
#bdereims@vmware.com

DATE=$( date +%Y%m%d-%H%M%S )

for CPODROUTER in $( cat cpodrouters); do
        echo $CPODROUTER
        NAME=$CPODROUTER-$DATE
        ssh $CPODROUTER "cd /root ; rm -fr backup.tgz ; tar --exclude-tag=exclude.tag -cvzf backup.tgz /etc /data"
        scp $CPODROUTER:/root/backup.tgz ${NAME}.tgz
	ls -tp1 ${CPODROUTER}* | tail -n +4 | xargs -I {} rm -- {}
done
