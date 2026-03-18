#!/bin/bash
set -e

# Ensure the database folder exists and has right permissions
chown -R mysql:mysql /var/lib/mysql

# Start MariaDB service in the background for setup
service mariadb start
sleep 2

# Verify if we can connect as root (with or without password)
if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
    DB_AUTH="-u root"
else
    DB_AUTH="-u root -p${MYSQL_ROOT_PASSWORD}"
fi

# 1. Setup Database and User for WordPress
# The @'%' is the critical fix for Error 1130
mysql $DB_AUTH -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql $DB_AUTH -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql $DB_AUTH -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"

# 2. Update Root security
mysql $DB_AUTH -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# 3. Shutdown background service to restart as PID 1
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "MariaDB initialized. Launching daemon..."
exec mysqld_safe
