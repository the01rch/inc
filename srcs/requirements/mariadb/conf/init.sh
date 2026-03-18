#!/bin/bash

set -e 

if [ -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "MARIADB Already installed"
    exec mysqld_safe
else 
    chown -R mysql:mysql /var/lib/mysql
    mkdir -p /var/run/mysqld
    chown mysql:mysql /var/run/mysqld
    chmod 777 /var/run/mysqld
    
    # Start service to configure it
    service mariadb start
    
    # Check if root password is already set or not
    try_connection=0;
    max_attempts_connection=10; # Increased for safety
    
    until mysql -u root -e "SELECT 1;" >/dev/null 2>&1 || mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
        try_connection=$((try_connection + 1))
        if [ "$try_connection" -ge "$max_attempts_connection" ] ; then
            echo "Unable to connect MariaDB root."
            exit 1
        fi
        echo "Waiting for MariaDB... ($try_connection/$max_attempts_connection)"
        sleep 3
    done
    
    # Define a variable to use the correct password flag for the following commands
    # If root without password works, use empty. If not, use the env password.
    if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        DB_AUTH="-u root"
    else
        DB_AUTH="-u root -p$MYSQL_ROOT_PASSWORD"
    fi

    # Create data base
    mysql $DB_AUTH -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    # Create admin user (using IF NOT EXISTS to avoid Error 1396)
    if mysql $DB_AUTH -e "CREATE USER IF NOT EXISTS \`${ADMIN_USER}\`@'%' IDENTIFIED BY '${ADMIN_PASSWORD}';" ; then
        mysql $DB_AUTH -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${ADMIN_USER}\`@'%';"
        echo "User ${ADMIN_USER} successfully created/verified."
    else
        echo "${ADMIN_USER} user couldnt be created."
        exit 1
    fi
    
    # Create second user
    if mysql $DB_AUTH -e "CREATE USER IF NOT EXISTS \`${USER1_LOGIN}\`@'%' IDENTIFIED BY '${USER1_PASSWORD}';" ; then
        mysql $DB_AUTH -e "GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO \`${USER1_LOGIN}\`@'%';"
        echo "User ${USER1_LOGIN} successfully created/verified."
    else
        echo "${USER1_LOGIN} user couldnt be created."
        exit 1
    fi
    
    # Set the root password last, otherwise you lock yourself out mid-script
    mysql $DB_AUTH -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
    
    # Shutdown properly to restart with mysqld_safe as PID 1
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
    
    echo "MariaDB setup finished."
    touch /tmp/mariadb_ready
    exec mysqld_safe

	chown -R www-data:www-data /var/www/html
	chmod -R 755 /var/www/html
fi
