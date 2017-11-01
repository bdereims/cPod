export NAME=DEV
./vic-machine-linux create \
--target vcsa.cpod-devops.shwrfr.mooo.com \
--user administrator@cpod-devops.shwrfr.mooo.com \
--password VMware1! \
--name VCH-${NAME} \
--thumbprint 09:9D:F2:78:DC:CD:79:E6:A4:81:3F:0C:6F:56:BC:B2:6D:4A:41:DE \
--compute-resource Rack01-NSX-V \
--management-network DPortGroup \
--bridge-network VIC-Bridge-${NAME} \
--no-tlsverify \
--image-store Datastore/VCH-${NAME} \
--volume-store Datastore:default \
--container-network DPortGroup:vic-routed \
--registry-ca=ca.crt 
