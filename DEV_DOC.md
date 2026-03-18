# Developer Documentation - Inception Project

## 1. Prerequisites

- Virtual Machine running **Debian Bullseye**
- **Docker** installed (v20+)
- **Docker Compose** installed (v2+ recommended)
- User added to the `docker` group: `sudo usermod -aG docker $USER`
- `/etc/hosts` configured: `127.0.0.1 redrouic.42.fr`

## 2. Repository structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── docker-compose.yml
    ├── .env                  ← NOT in git, must be created manually
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/
        │       ├── 50-server.cnf
        │       └── init.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── conf/
                ├── auto_config.sh
                └── www.conf
```

## 3. Environment setup

Create `srcs/.env` with the following variables (never commit this file):

```env
DOMAIN_NAME=redrouic.42.fr

MYSQL_DATABASE=inception_db
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=redrouic
MYSQL_PASSWORD=your_password

WP_ADMIN_USER=redrouic
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=redrouic@student.42.fr

USER1_LOGIN=second_user
USER1_MAIL=guest@42.fr
USER1_PASSWORD=your_user_password
```

Also add to `/etc/hosts` on the VM:
```
127.0.0.1 redrouic.42.fr
```

## 4. Build and launch

```bash
# Full build and start
make

# This runs:
# mkdir -p /home/redrouic/data/mariadb
# mkdir -p /home/redrouic/data/wordpress
# docker-compose -f ./srcs/docker-compose.yml up -d --build
```

## 5. Useful Docker Compose commands

```bash
# View running containers
docker compose -f srcs/docker-compose.yml ps

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Stop containers
docker compose -f srcs/docker-compose.yml down

# Stop and remove volumes
docker compose -f srcs/docker-compose.yml down -v

# Rebuild everything from scratch
make fclean && make
```

## 6. Container management

```bash
# Enter MariaDB container
docker exec -it my_mariadb_container bash

# Enter WordPress container
docker exec -it my_wordpress_container bash

# Enter NGINX container
docker exec -it my_nginx_container bash

# Connect directly to the database
docker exec -it my_mariadb_container mariadb -u redrouic -p inception_db
```

## 7. Data persistence

Data is stored on the host machine at:
- `/home/redrouic/data/mariadb/` — MariaDB database files
- `/home/redrouic/data/wordpress/` — WordPress source files

These directories are bind-mounted into the containers via named Docker volumes defined in `docker-compose.yml`. Data persists across container restarts and even after `docker compose down`. Only `make fclean` deletes the data.

## 8. Startup order

The startup sequence is enforced by `depends_on` with `condition: service_healthy`:

1. **MariaDB** starts first and runs `init.sh` which creates the database and user, then touches `/tmp/mariadb_ready`
2. The **healthcheck** in docker-compose.yml verifies the file exists and MariaDB accepts connections
3. **WordPress** only starts after MariaDB passes the healthcheck, then runs `auto_config.sh` which downloads and configures WordPress via WP-CLI
4. **NGINX** starts after WordPress is up and serves requests on port 443
