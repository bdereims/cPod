#!/bin/bash

#apt -y update

export DEBIAN_FRONTEND=noninteractive
apt -y install mysql-client mysql-server phpmyadmin

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

/etc/init.d/apache2 restart
/etc/init.d/mysql restart
