#/bin/bash -x
#bdereims@vmware.com

### Configure this host as cPodRouter ###
### Assuming connected to Internet    ### 

### at least 1 vCPUi, 1Go for Memory and 8Go for Disk

DIR=conf.d
MISC=misc
BITS=BITS
NAME=cpodrouter

#Update for the role
tdnf -y update
tdnf -y install dnsmasq git sshpass ntp nginx tar wget

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

#Install BGP Quagga deamon
groupadd quagga
useradd quagga -g quagga
MYDIR=$(pwd)
cd /
tar xvzf ${MYDIR}/${MISC}/quagga.tgz
cd -

#Install OVFTOOL
MYDIR=$(pwd)
cd /root
tar xvzf ${MYDIR}/${MISC}/ovftool.tgz
cd -

#Create BITS dir
mkdir -p /root/BITS
cp ${BITS}/* /root/BITS/.

#Install Photon CLI
mkdir -p /tmp/$$
cd /tmp/$$
wget https://github.com/vmware/photon-controller/releases/download/v1.1.0/photon-linux64-1.1.0-5de1cb7
PHOTONCLI=$(ls -1 photon-linux*)
cp ${PHOTONCLI} /usr/bin/photon
chmod +x /usr/bin/photon
cd -
rm -fr /tmp/$$

#PowerCLIcore Container
systemctl start docker
docker pull vmware/powerclicore

#Statup scripts
systemctl enable dnsmasq
systemctl enable ntpd
systemctl enable nginx 
systemctl enable bgpd
systemctl enable docker 
