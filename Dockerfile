# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: hkono <hkono@student.42tokyo.jp>           +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/05/02 17:02:36 by hkono             #+#    #+#              #
#    Updated: 2021/05/02 17:02:51 by hkono            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update && apt-get -y install	\
	nginx				\
	wget				\
	mariadb-server		\
	mariadb-client		\
	php-cgi				\
	php-common			\
	php-fpm				\
	php-pear			\
	php-mbstring		\
	php-zip				\
	php-net-socket		\
	php-gd				\
	php-xml-util		\
	php-gettext			\
	php-mysql			\
	php-bcmath

ENV AUTO_INDEX on

COPY srcs/service_start.sh /
COPY srcs/autoindex_option.sh /
COPY srcs/config.inc.php /tmp/config.inc.php
COPY srcs/wp-config.php /tmp/wp-config.php
COPY srcs/nginx-conf /tmp/nginx-conf
COPY srcs/nginx-conf-off /tmp/nginx-conf-off

WORKDIR /tmp

RUN mkdir /var/www/ft_server

# install wordpress
RUN wget https://ja.wordpress.org/latest-ja.tar.gz
RUN tar xaf latest-ja.tar.gz
RUN rm -rf latest-ja.tar.gz
RUN mv wordpress /var/www/ft_server/
RUN mv wp-config.php /var/www/ft_server/wordpress/

# install phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN tar -xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN rm -rf phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.0.1-all-languages/ /var/www/ft_server/phpmyadmin
RUN mv config.inc.php /var/www/ft_server/phpmyadmin/

RUN chown -R www-data /var/www/*
RUN chmod -R 755 /var/www/*

# setup nginx
RUN ln -s /etc/nginx/sites-available/ft_server /etc/nginx/sites-enabled/ft_server
RUN rm -rf /etc/nginx/sites-enabled/default

# SSL
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/ft_server.pem -keyout /etc/nginx/ssl/ft_server.key -subj "/C=JP/ST=Tokyo/L=42Network/O=42Tokyo/OU=hkono/CN=ft_server"

WORKDIR /

CMD ["bash", "/service_start.sh"]
