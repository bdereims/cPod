# docker-mysql-phpmyadmin

Dockerfile that creates an image with mysql + phpmyadmin.
MySQL is fully automated, it's not yet the case for phpmyadmin. It requires to connect to the running container and reconfigure the package :

	# ./build.sh
	# ./run-server.sh
	# docker ps
	# docker exec -t -i <CONTAINER_ID> bash

	# dpkg-reconfigure phpmyadmin
