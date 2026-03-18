#!/bin/bash

sleep 10
set -e
set -x

if [ ! -f '/var/www/html/wordpress/wp-config.php' ]; then
    cd /var/www/html
    wget -q https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz 
    tar -xzf wordpress-6.6-fr_FR.tar.gz
    rm wordpress-6.6-fr_FR.tar.gz
    chown -R www-data:www-data wordpress
fi

cd /var/www/html/wordpress
if ! wp core is-installed --allow-root --path='/var/www/html/wordpress' > /dev/null 2>&1; then
wp config create --allow-root --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${ADMIN_USER}" \
                     --dbpass="${ADMIN_PASSWORD}" \
                     --dbhost=mariadb:3306 \
                     --path='/var/www/html/wordpress';
chown www-data:www-data /var/www/html/wordpress/wp-config.php


    wp core install --allow-root \
                    --url="${DOMAIN_NAME}" \
                    --title="${SITE_TITLE}" \
                    --admin_user="${ADMIN_USER}" \
                    --admin_password="${ADMIN_PASSWORD}" \
                    --path='/var/www/html/wordpress' \
                    --admin_email="${ADMIN_MAIL}";

    wp user create  --allow-root \
                    ${USER1_LOGIN} ${USER1_MAIL} \
                    --role=author \
                    --user_pass=${USER1_PASSWORD} \
                    --path='/var/www/html/wordpress';

    wp cache flush --allow-root --path='/var/www/html/wordpress'

fi

exec /usr/sbin/php-fpm7.4 -F -R
