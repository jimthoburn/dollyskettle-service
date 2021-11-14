# You can change this to a different version of Wordpress available at
# https://hub.docker.com/_/wordpress
FROM wordpress:5.3.2-apache

RUN apt-get update && apt-get install -y magic-wormhole

RUN apt-get update && apt-get install -y default-mysql-client

USER www-data:www-data
