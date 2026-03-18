#!/bin/bash

# Wait for MariaDB to be ready (Dynamic check)
echo "Waiting for MariaDB..."
while ! mariadb-admin ping -h"mariadb" --silent; do
    sleep 1
done
echo "MariaDB is up!"

set -x

# 1. Download WordPress
if [ ! -d "/var/www/html/wordpress" ]; then
    mkdir -p /var/www/html
    cd /var/www/html
    wget -q https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz 
    tar -xzf wordpress-6.6-fr_FR.tar.gz
    rm wordpress-6.6-fr_FR.tar.gz
fi

cd /var/www/html/wordpress

# 2. Configure and Install
if [ ! -f "wp-config.php" ]; then
    # Create config (Matches the MYSQL_USER from init.sh)
    wp config create --allow-root \
                     --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${MYSQL_USER}" \
                     --dbpass="${MYSQL_PASSWORD}" \
                     --dbhost=mariadb:3306 \
                     --path='/var/www/html/wordpress'
    
    # Install WordPress
    wp core install --allow-root \
                    --url="${DOMAIN_NAME}" \
                    --title="Inception" \
                    --admin_user="${WP_ADMIN_USER}" \
                    --admin_password="${WP_ADMIN_PASSWORD}" \
                    --admin_email="${WP_ADMIN_EMAIL}" \
                    --path='/var/www/html/wordpress'

    # Create the second mandatory user
    wp user create --allow-root \
                    "second_user" "second_user@example.com" \
                    --role=author \
                    --user_pass="user_pass_42" \
                    --path='/var/www/html/wordpress'
else
    echo "WordPress already configured."
fi

# 3. Permissions
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# 4. Start PHP-FPM in foreground (MANDATORY PID 1)
echo "Starting PHP-FPM..."
mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F
