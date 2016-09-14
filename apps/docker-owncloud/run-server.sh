#!/bin/sh

VOLUME=/data/lv-raid5/Docker/Volumes/owncloud

docker run -d -p 8080:80 -p 8443:443 -v ${VOLUME}:/var/www/owncloud/data bdereims/owncloud 
