#/bin/bash -x
#bdereims@vmware.com

### Configure this host as cPodRouter ###
### Assuming connected to Internet    ### 

DIR=conf.d
NAME=cpodrouter

#Update for the role
tdnf -y update
tdnf -y install dnsmasq git sshpass ntp nginx tar

#Change name
echo $NAME > /etc/hostname

#Banner
cp ${DIR}/issue /etc/.
rm -fr /etc/issue.net
ln -s /etc/issue /etc/issue.net
cp ${DIR}/photon.png /boot/grub2/themes/photon/.

#Network configuration
rm -fr /etc/systemd/network/10-dhcp-en.network
cp ${DIR}/*network /etc/systemd/network
chmod o+r /etc/systemd/network/*
cp ${DIR}/iptables /etc/systemd/scripts/.
cp ${DIR}/99-sysctl.conf /etc/sysctl.d/.
cp ${DIR}/hosts /etc/.

#Allow ssh root login
cp ${DIR}/sshd_config /etc/ssh/.

#DNS/DHCP
cp ${DIR}/dnsmasq.conf /etc/.

#NTP Configuration
cp ${DIR}/ntp.conf /etc/.
ntpdate ntp.org

#Web Portal
MYDIR=$(pwd)
cd /etc/nginx
tar xvzf ${MYDIR}/${DIR}/html.tgz
cd -

#Generate SSH keys
cd /root
rm -fr .ssh
cat /dev/zero | ssh-keygen -q -N "" -t rsa
cd -

#Statup scripts
systemctl enable dnsmasq
systemctl enable ntpd
systemctl enable nginx 
