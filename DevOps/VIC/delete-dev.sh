export NAME=DEV
./vic-machine-linux delete \
--target vcsa.cpod-devops.shwrfr.mooo.com \
--user administrator@cpod-devops.shwrfr.mooo.com --password VMware1! \
--name VCH-${NAME} \
--thumbprint 09:9D:F2:78:DC:CD:79:E6:A4:81:3F:0C:6F:56:BC:B2:6D:4A:41:DE \
--compute-resource Rack01-NSX-V
rm -fr VCH-${NAME}
