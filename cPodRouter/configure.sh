#/bin/bash -x
#bdereims@vmware.com
 
### Configure this host as cPodRouter ###
### Assuming connected to Internet    ### 

### at least 1 vCPUi, 1Go for Memory and 8Go for Disk

[ "$( hostname )" == "mgmt-cpodrouter" ] && exit 1

DIR=conf.d
MISC=misc
BITS=BITS
NAME=cpodrouter

#Update root passwd expiration
chage -I -1 -m 0 -M 99999 -E -1 root

#Update for the role
tdnf -y update
tdnf -y install dnsmasq git sshpass ntp nginx tar wget nfs-utils

#Change name
echo $NAME > /etc/hostname

#Banner
cp ${DIR}/issue /etc/.
rm -fr /etc/issue.net
ln -s /etc/issue /etc/issue.net
cp ${DIR}/photon.png /boot/grub2/themes/photon/.

#Network configuration
rm -fr /etc/systemd/network/*
cp ${DIR}/*network /etc/systemd/network
chmod o+r /etc/systemd/network/*
cp ${DIR}/iptables /etc/systemd/scripts/.
cp ${DIR}/99-sysctl.conf /etc/sysctl.d/.
cp ${DIR}/hosts /etc/.

#Allow ssh root login
cp ${DIR}/sshd_config /etc/ssh/.

#DNS/DHCP
cp ${DIR}/dnsmasq.conf /etc/.
chmod 0755 /etc/dnsmasq.conf

#NTP Configuration
cp ${DIR}/ntp.conf /etc/.
chown ntp:ntp /etc/ntp.conf
chmod 0644 /etc/ntp.conf
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

#Install tmux 
MYDIR=$(pwd)
cd /
tar xvzf ${MYDIR}/${MISC}/tmux.tgz
locale-gen.sh
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
chmod ugo+rx /usr/bin/photon
cd -
rm -fr /tmp/$$

#Install jq 1.5
mkdir -p /tmp/$$
cd /tmp/$$
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
mv jq-linux64 /usr/bin/jq
chmod ugo+rx /usr/bin/jq 
cd -
rm -fr /tmp/$$

#Install docker-compose
mkdir -p /tmp/$$
cd /tmp/$$
wget https://github.com/docker/compose/releases/download/1.11.2/docker-compose-Linux-x86_64
mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
chmod ugo+rx /usr/local/bin/docker-compose
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
