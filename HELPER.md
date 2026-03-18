# 🎯 Inception Evaluation Cheatsheet

## 📋 Project Summary

Inception is a 42 school sysadmin project where you build a mini infrastructure using **Docker Compose** inside a **Virtual Machine**.

**3 containers, all built from scratch (Debian Bullseye):**
- **NGINX** — the only entry point, HTTPS port 443, TLS v1.2/v1.3, reverse proxy to WordPress
- **WordPress + PHP-FPM** — the CMS, no nginx inside, talks to MariaDB on port 3306
- **MariaDB** — the database, no nginx inside, only reachable from inside the Docker network

**2 volumes** for persistence → stored at `/home/redrouic/data/` on the host machine
**1 Docker network** (bridge) → containers talk to each other using service names as DNS

Everything is configured via a `.env` file (never committed to git).
`make` builds and starts everything. `make fclean` wipes everything.

---

## 🗣️ QUESTIONS YOU'LL BE ASKED

**How does Docker work?**
> Docker packages an app and its dependencies into a container that shares the host OS kernel. Each container is isolated but lightweight compared to a VM.

**How does Docker Compose work?**
> Docker Compose reads a `docker-compose.yml` file and orchestrates multiple containers — handling build, startup order, networking and volumes in one command.

**Docker image with compose vs without?**
> Without compose: you run `docker build` and `docker run` manually for each container. With compose: one `docker compose up --build` builds and starts everything automatically.

**Docker vs VMs?**
> VMs emulate a full OS with their own kernel — heavy and slow to start. Docker containers share the host kernel — lighter, faster, more portable.

**What is a Docker network?**
> An isolated virtual network that lets containers communicate using service names as DNS (e.g. `mariadb`, `wordpress`) without exposing ports to the host.

**Why this directory structure?**
> Subject requires all config in `srcs/`, one Dockerfile per service, a Makefile at root. This keeps services modular and isolated.

**How to login to the database?**
```bash
docker exec -it my_mariadb_container mariadb -u redrouic -p inception_db
```

---

## ✅ EVAL COMMANDS — run these when asked

**Reset Docker before evaluation (evaluator runs this):**
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```

**Start the project:**
```bash
make
```

**Check all containers are running:**
```bash
docker compose -f srcs/docker-compose.yml ps
```

**Check network exists:**
```bash
docker network ls
```

**Check volumes exist:**
```bash
docker volume ls
docker volume inspect srcs_mariadb_volume
docker volume inspect srcs_wordpress_volume
```
> Must show `/home/redrouic/data/` in the output

**Check TLS version:**
```bash
curl -kv https://redrouic.42.fr 2>&1 | grep "SSL connection"
```
> Must show TLSv1.2 or TLSv1.3

**Check port 80 is blocked:**
```bash
curl http://redrouic.42.fr
```
> Must fail / timeout

**Check port 443 works:**
```bash
curl -k https://redrouic.42.fr
```
> Must return HTML

**Verify database is not empty:**
```bash
docker exec -it my_mariadb_container mariadb -u redrouic -p inception_db -e "SHOW TABLES;"
```

---

## 🔄 PERSISTENCE TEST

```bash
sudo reboot
# after reboot:
make
curl -k https://redrouic.42.fr
# your previous changes must still be there
```

---

## 🔧 CONFIGURATION MODIFICATION TEST

The evaluator will ask you to change a port. Example: change NGINX from 443 to 8443.

**Step 1 — Edit docker-compose.yml:**
```yaml
ports:
  - "8443:443"   # change 443:443 to 8443:443
```

**Step 2 — Rebuild:**
```bash
make fclean
make
```

**Step 3 — Test:**
```bash
curl -k https://redrouic.42.fr:8443
```

---

## 📁 KEY FILE LOCATIONS

| File | Path |
|---|---|
| docker-compose | `srcs/docker-compose.yml` |
| .env (NOT in git) | `srcs/.env` |
| MariaDB Dockerfile | `srcs/requirements/mariadb/Dockerfile` |
| MariaDB init script | `srcs/requirements/mariadb/conf/init.sh` |
| NGINX Dockerfile | `srcs/requirements/nginx/Dockerfile` |
| NGINX config | `srcs/requirements/nginx/conf/nginx.conf` |
| WordPress Dockerfile | `srcs/requirements/wordpress/Dockerfile` |
| WordPress setup | `srcs/requirements/wordpress/conf/auto_config.sh` |
| Data on host | `/home/redrouic/data/` |

---

## 👤 CREDENTIALS

| What | Value |
|---|---|
| WP admin user | `redrouic` |
| WP admin panel | `https://redrouic.42.fr/wp-admin` |
| DB name | `inception_db` |
| DB user | `redrouic` |
| Second WP user | `second_user` (role: author) |

---

## ⚡ QUICK DEBUG

```bash
# See logs
make logs

# Enter a container
docker exec -it my_mariadb_container bash
docker exec -it my_wordpress_container bash
docker exec -it my_nginx_container bash

# Full rebuild
make fclean && make
```
