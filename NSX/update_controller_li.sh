#!/bin/sh

MYSCRIPT=$$
CREDENTIALS=admin:VMware1!
NSXMGR=nsx.cpod.net

NSXCTRL=1
curl -k -u ${CREDENTIALS} --header "Content-Type:text/xml;charset=UTF-8" -d @nsxctrl.xml -X POST https://${NSXMGR}/api/2.0/vdn/controller/controller-${NSXCTRL}/syslog

echo "--Check Settings--"
curl -k -u ${CREDENTIALS} -X GET https://${NSXMGR}/api/2.0/vdn/controller/controller-${NSXCTRL}/syslog

