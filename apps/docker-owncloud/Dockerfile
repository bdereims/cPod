FROM debian
MAINTAINER Brice Dereims "bdereims@gmail.com"

# System Update amd packages installation
RUN apt-get -y update
RUN apt-get install -y apache2 php5 php5-gd php-xml-parser php5-intl php5-mysqlnd php5-json php5-mcrypt php-apc smbclient curl libcurl3 php5-curl bzip2 wget openssl
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Owncloud
RUN curl -k https://download.owncloud.org/community/owncloud-8.1.1.tar.bz2 | tar jx -C /var/www/
RUN mkdir /var/www/owncloud/data
RUN chown -R www-data:www-data /var/www/owncloud

# Configure apache and use ssl
ADD ./001-owncloud.conf /etc/apache2/sites-available/
RUN rm -f /etc/apache2/sites-enabled/000*
RUN ln -s /etc/apache2/sites-available/001-owncloud.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite
RUN a2enmod ssl 
RUN mkdir -p /etc/apache2/ssl
ADD ./openssl.cnf /etc/apache2/ssl/openssl.cnf
RUN openssl req -new -x509 -config /etc/apache2/ssl/openssl.cnf -days 1095 -newkey rsa:2048 -nodes -out /etc/apache2/ssl/owncloud.crt -keyout /etc/apache2/ssl/owncloud.key

# [Optional] Keep the owncloud config
#ADD ./config.php /var/www/owncloud/config/config.php
#RUN chown www-data:www-data /var/www/owncloud/config/config.php

ADD ./startup.sh /opt/startup.sh

EXPOSE 80 
EXPOSE 443

CMD ["/bin/bash", "/opt/startup.sh"]
