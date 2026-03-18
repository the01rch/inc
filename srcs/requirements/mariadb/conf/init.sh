#!/bin/bash

set -e 

if [ -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
	echo "MARIADB Already installed"
	mysqld_safe
else 
	chown -R mysql:mysql /var/lib/mysql
	mkdir -p /var/run/mysqld
	chown mysql:mysql /var/run/mysqld
	chmod 777 /var/run/mysqld
	
	# Try to connect [max_attempts_connection] before to message error and stop 
	try_connection=0;
	max_attempts_connection=4;
	service mariadb start
	until mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "" ; do
		try_connection=$((try_connection + 1))
		if [ "$try_connection" -ge "$max_attempts_connection" ] ; then
			echo "Enable to connect MariaDB root. Make sure have the right password. The issues could also due to a bad container setting, check if listening port is available and if setting files are correctly shared. If everythings are correct, you can try to increse [max_attempts_connection] (l.10) in ./mariadb/conf/init.sh file"
			exit 1
		fi
		sleep 7
	done
	
	# Create data base with user root
	mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
	
	# Create admin user and guest using docker secret files
	if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER \`${ADMIN_USER}\` @'%' IDENTIFIED BY '${ADMIN_PASSWORD}';" ; then
		echo "User ${ADMIN_USER} successfully created."
	else
		echo "${ADMIN_USER} user couldnt be created."
		exit 1
	fi
	if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${ADMIN_USER}\`@'%' IDENTIFIED BY '${ADMIN_PASSWORD}';" ; then
		echo "\`${ADMIN_USER}\` privileges changed."
	else 
		echo "\`${ADMIN_USER}\` privileges couldn't be changed."
		exit 1
	fi
	
	if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER \`${USER1_LOGIN}\` @'%' IDENTIFIED BY \"${USER1_PASSWORD}\";" ; then
		echo "User ${USER1_LOGIN} succesfully created."
	else
		echo "${USER1_LOGIN} user couldnt be created."
		exit 1
	fi
	if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO \`${USER1_LOGIN}\`@'%' IDENTIFIED BY '${USER1_PASSWORD}';" ; then
		echo "\`${USER1_LOGIN}\` privileges changed."
	else 
		echo "\`${USER1_LOGIN}\` privileges couldn't be changed."
		exit 1
	fi
	sleep 5
	
	mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
	sleep 5
	mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
	
	touch /tmp/mariadb_ready
	exec mysqld_safe
	
fi
