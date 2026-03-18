#!/bin/bash

sleep 10
# We remove set -e for a moment to handle existing files gracefully
set -x

#  Download WordPress if the folder doesn't exist
if [ ! -d "/var/www/html/wordpress" ]; then
    mkdir -p /var/www/html
    cd /var/www/html
    wget -q https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz 
    tar -xzf wordpress-6.6-fr_FR.tar.gz
    rm wordpress-6.6-fr_FR.tar.gz
    chown -R www-data:www-data /var/www/html/wordpress
fi

cd /var/www/html/wordpress

#  Check if wp-config already exists before trying to create it
if [ ! -f "wp-config.php" ]; then
    wp config create --allow-root \
                     --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${SQL_USER}" \
                     --dbpass="${SQL_PASSWORD}" \
                     --dbhost=mariadb:3306 \
                     --path='/var/www/html/wordpress'
    
    wp core install --allow-root \
                    --url="${DOMAIN_NAME}" \
                    --title="${SITE_TITLE}" \
                    --admin_user="${ADMIN_USER}" \
                    --admin_password="${ADMIN_PASSWORD}" \
                    --admin_email="${ADMIN_MAIL}" \
                    --path='/var/www/html/wordpress'

    wp user create  --allow-root \
                    "${USER1_LOGIN}" "${USER1_MAIL}" \
                    --role=author \
                    --user_pass="${USER1_PASSWORD}" \
                    --path='/var/www/html/wordpress'
else
    echo "WordPress already configured."
fi

# Final Permissions fix
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# START SERVICE (Note: No -R, and correct path)
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
