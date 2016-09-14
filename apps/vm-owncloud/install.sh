#!/bin/bash

#apt-get -y update
apt-get install -y apache2 php5 php5-gd php-xml-parser php5-intl php5-mysqlnd php5-json php5-mcrypt php-apc smbclient curl libcurl3 php5-curl bzip2 wget openssl
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

curl -k https://download.owncloud.org/community/owncloud-8.1.1.tar.bz2 | tar jx -C /var/www/
mkdir -p /var/www/owncloud/data
chown -R www-data:www-data /var/www/owncloud

cp ./001-owncloud.conf /etc/apache2/sites-available/
rm -f /etc/apache2/sites-enabled/000*
ln -s /etc/apache2/sites-available/001-owncloud.conf /etc/apache2/sites-enabled/
a2enmod rewrite
a2enmod ssl 
mkdir -p /etc/apache2/ssl
cp ./openssl.cnf /etc/apache2/ssl/openssl.cnf
openssl req -new -x509 -config /etc/apache2/ssl/openssl.cnf -days 1095 -newkey rsa:2048 -nodes -out /etc/apache2/ssl/owncloud.crt -keyout /etc/apache2/ssl/owncloud.key

/etc/init.d/apache2 restart
