#!/bin/bash
set -e 

# Check if the database already exists to skip setup on restart
if [ -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "MARIADB already initialized. Starting..."
    exec mysqld_safe
else 
    # Proper folder permissions
    chown -R mysql:mysql /var/lib/mysql
    mkdir -p /var/run/mysqld
    chown mysql:mysql /var/run/mysqld
    chmod 777 /var/run/mysqld
    
    # Start MariaDB service temporarily to configure it
    service mariadb start
    sleep 2

    # 1. Determine current root access (with or without password)
    if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        DB_AUTH="-u root"
    else
        DB_AUTH="-u root -p${MYSQL_ROOT_PASSWORD}"
    fi

    # 2. Create the Database
    mysql $DB_AUTH -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    # 3. Create the WordPress User (MUST match MYSQL_USER in auto_config.sh)
    # We use @'%' so it can be accessed from the WordPress container
    mysql $DB_AUTH -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql $DB_AUTH -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    
    # 4. Set/Update Root Password
    mysql $DB_AUTH -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
    
    # 5. Shutdown the temporary service properly
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    
    echo "MariaDB setup finished successfully."
    
    # 6. Launch MariaDB in the foreground (PID 1)
    exec mysqld_safe
fi
