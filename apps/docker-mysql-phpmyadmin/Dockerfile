FROM debian 
MAINTAINER Brice Dereims "bdereims@gmail.com"

RUN apt-get update

RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y install mysql-client mysql-server phpmyadmin

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

ADD ./startup.sh /opt/startup.sh

EXPOSE 3306
EXPOSE 80

CMD ["/bin/bash", "/opt/startup.sh"]
