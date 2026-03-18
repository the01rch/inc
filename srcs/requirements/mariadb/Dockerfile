FROM debian:bullseye

RUN apt update
RUN apt upgrade -y
RUN apt install -y mariadb-server
RUN apt install -y procps

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chown mysql:mysql /etc/mysql/mariadb.conf.d/50-server.cnf
RUN mkdir -p /var/run/mysql
RUN chown -R mysql:mysql /var/run/mysql
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY conf/init.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

EXPOSE 3306

ENTRYPOINT ["bash", "/docker-entrypoint-initdb.d/init.sh"]	
