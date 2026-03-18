#!/bin/bash

# Attendre que MariaDB soit prête avant de lancer les commandes WP-CLI
# On utilise mariadb-admin ping au lieu d'une boucle infinie (prohibée par le sujet)
echo "Waiting for MariaDB..."
while ! mariadb-admin ping -h"mariadb" --silent; do
    sleep 1
done
echo "MariaDB is up and running!"

set -x

# 1. Download WordPress if it's not already there
if [ ! -d "/var/www/html/wordpress" ]; then
    mkdir -p /var/www/html
    cd /var/www/html
    wget -q https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz 
    tar -xzf wordpress-6.6-fr_FR.tar.gz
    rm wordpress-6.6-fr_FR.tar.gz
fi

cd /var/www/html/wordpress

# 2. Configure and Install WordPress
# We check for wp-config.php existence to ensure persistence works after reboot 
if [ ! -f "wp-config.php" ]; then
    # Create wp-config.php using variables from .env 
    wp config create --allow-root \
                     --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${MYSQL_USER}" \
                     --dbpass="${MYSQL_PASSWORD}" \
                     --dbhost=mariadb:3306 \
                     --path='/var/www/html/wordpress'
    
    # Install WordPress Core
    wp core install --allow-root \
                    --url="${DOMAIN_NAME}" \
                    --title="Inception" \
                    --admin_user="${WP_ADMIN_USER}" \
                    --admin_password="${WP_ADMIN_PASSWORD}" \
                    --admin_email="${WP_ADMIN_EMAIL}" \
                    --path='/var/www/html/wordpress'

    # Create the second user (Mandatory part: two users required) 
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
# We use 'exec' to replace the shell process with PHP-FPM. 
# This makes PHP-FPM the PID 1 of the container[cite: 105].
echo "Starting PHP-FPM..."
mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F
