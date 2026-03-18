#!/bin/bash

# Wait for MariaDB to be ready
sleep 10

set -x

# 1. Download WordPress if it's not already there
if [ ! -d "/var/www/html/wordpress" ]; then
    mkdir -p /var/www/html
    cd /var/www/html
    wget -q https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz 
    tar -xzf wordpress-6.6-fr_FR.tar.gz
    rm wordpress-6.6-fr_FR.tar.gz
    chown -R www-data:www-data /var/www/html/wordpress
fi

cd /var/www/html/wordpress

# 2. Configure and Install WordPress
# Using the exact variable names from your .env file
if [ ! -f "wp-config.php" ]; then
    wp config create --allow-root \
                     --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${MYSQL_USER}" \
                     --dbpass="${MYSQL_PASSWORD}" \
                     --dbhost=mariadb:3306 \
                     --path='/var/www/html/wordpress'
    
    wp core install --allow-root \
                    --url="${DOMAIN_NAME}" \
                    --title="Inception" \
                    --admin_user="${WP_ADMIN_USER}" \
                    --admin_password="${WP_ADMIN_PASSWORD}" \
                    --admin_email="${WP_ADMIN_EMAIL}" \
                    --path='/var/www/html/wordpress'

    # Note: Ensure these USER1 variables exist in your .env or replace them here
    wp user create --allow-root \
                    "second_user" "second_user@example.com" \
                    --role=author \
                    --user_pass="user_pass_42" \
                    --path='/var/www/html/wordpress'
else
    echo "WordPress already configured."
fi

# 3. Final Permissions fix
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# 4. START SERVICE
echo "Starting PHP-FPM..."
# Ensure /run/php exists for the PID file
mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F
