#!/bin/sh

VOLUME=/root/ownclound

mkdir -p $VOLUME
chown -R 33:33 $VOLUME

docker run -d -p 8080:80 -p 8443:443 -v ${VOLUME}:/var/www/owncloud/data bdereims/owncloud 
