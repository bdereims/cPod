#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vmware/bin

apt-get -y update

export DEBIAN_FRONTEND=noninteractive
apt-get -y install mysql-client mysql-server phpmyadmin

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'VMware1!' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

/etc/init.d/apache2 restart
/etc/init.d/mysql restart
