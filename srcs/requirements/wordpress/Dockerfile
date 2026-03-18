FROM debian:bullseye

RUN apt clean
RUN apt -y update 
RUN apt -y upgrade
RUN apt -y install wget
RUN apt -y install -y php7.4 php7.4-fpm php7.4-mysql mariadb-client
RUN apt install -y curl
RUN apt install -y sendmail

#Wordpress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && chown www-data:www-data /run/php

COPY conf/auto_config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/auto_config.sh

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9000

ENTRYPOINT [ "bash", "auto_config.sh" ]