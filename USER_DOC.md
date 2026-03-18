# User Documentation - Inception Project

## Services provided by the stack

| Service | Role | Access |
|---|---|---|
| NGINX | Web server / reverse proxy | https://redrouic.42.fr (port 443) |
| WordPress + PHP-FPM | CMS application | Via NGINX |
| MariaDB | Database | Internal only (port 3306) |

## Starting and stopping the project

**Start:**
```bash
make
```

**Stop (keeps data):**
```bash
make down
```

**Full reset (deletes all data):**
```bash
make fclean
```

## Accessing the website and administration panel

- **Website**: https://redrouic.42.fr
- **Admin panel**: https://redrouic.42.fr/wp-admin

> Your browser will show a certificate warning because the SSL certificate is self-signed. Click "Advanced" then "Proceed" to continue.

## Credentials

All credentials are stored in `srcs/.env` on the host machine. This file is **never committed to git**.

| Credential | Variable in .env |
|---|---|
| WordPress admin username | `WP_ADMIN_USER` |
| WordPress admin password | `WP_ADMIN_PASSWORD` |
| Database name | `MYSQL_DATABASE` |
| Database user | `MYSQL_USER` |
| Database password | `MYSQL_PASSWORD` |
| MariaDB root password | `MYSQL_ROOT_PASSWORD` |

## Checking that services are running correctly

**Check all containers are up:**
```bash
docker compose -f srcs/docker-compose.yml ps
```
All three containers (`my_mariadb_container`, `my_wordpress_container`, `my_nginx_container`) should show status `Up`.

**Check container logs:**
```bash
make logs
```

**Check volumes exist:**
```bash
docker volume ls
docker volume inspect srcs_mariadb_volume
docker volume inspect srcs_wordpress_volume
```

**Test HTTPS access:**
```bash
curl -k https://redrouic.42.fr
```
You should get HTML back.

**Connect to the database:**
```bash
docker exec -it my_mariadb_container mariadb -u redrouic -p inception_db
```
