*This project has been created as part of the 42 curriculum by redrouic.*

# Inception - 42 Project

## Description

This project consists of setting up a small infrastructure of several services using Docker Compose inside a virtual machine. The goal is to learn system administration through the use of Docker containers.

The infrastructure includes:
- A Docker container with **NGINX** (TLS v1.2/v1.3 only, port 443)
- A Docker container with **WordPress** + **php-fpm** (no nginx)
- A Docker container with **MariaDB** (no nginx)
- Two named volumes for data persistence (database and WordPress files)
- A custom Docker bridge network for inter-container communication

## Project Description

### Docker in this project
Each service runs in its own dedicated container built from a custom Dockerfile based on Debian Bullseye. Docker Compose orchestrates the startup order and networking between containers. All images are built locally — no pre-built images from DockerHub are used (except the base Debian image).

### Virtual Machines vs Docker
A Virtual Machine emulates an entire operating system with its own kernel, requiring significant resources. Docker containers share the host kernel and are much lighter, faster to start, and easier to reproduce. VMs offer stronger isolation; Docker offers better portability and efficiency.

### Secrets vs Environment Variables
Environment variables (`.env` file) store configuration values that are passed into containers at runtime. Docker Secrets are more secure — they store sensitive data encrypted and expose it only to authorized services via `/run/secrets/`. For this project, environment variables via `.env` are used, with the `.env` file excluded from version control.

### Docker Network vs Host Network
A Docker network creates an isolated virtual network between containers, allowing them to communicate using service names as DNS. Host network mode removes this isolation and shares the host's network stack directly, which is forbidden in this project for security reasons.

### Docker Volumes vs Bind Mounts
Docker named volumes are managed by Docker and stored in Docker's internal directory. Bind mounts directly map a host directory into the container. This project uses named volumes configured to store data in `/home/redrouic/data/` on the host, ensuring persistence across container restarts.

## Instructions

### Prerequisites
- A Virtual Machine running Debian Bullseye
- Docker and Docker Compose installed
- Your user added to the `docker` group
- `redrouic.42.fr` pointing to `127.0.0.1` in `/etc/hosts`

### Setup
1. Clone the repository
2. Create the `.env` file inside `srcs/`:
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
3. Run at the root of the repository:
```bash
make
```
4. Access the site at `https://redrouic.42.fr`

### Makefile commands
| Command | Description |
|---|---|
| `make` | Build and start all containers |
| `make down` | Stop and remove containers |
| `make clean` | Same as down |
| `make fclean` | Remove containers, volumes and data |
| `make re` | Full rebuild |
| `make logs` | Show container logs |
| `make ls` | List Docker objects |

## Resources

### Documentation
- [Docker official docs](https://docs.docker.com/)
- [Docker Compose docs](https://docs.docker.com/compose/)
- [NGINX docs](https://nginx.org/en/docs/)
- [MariaDB docs](https://mariadb.com/kb/en/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### AI Usage
Claude (Anthropic) was used during this project for the following tasks:
- Diagnosing the MariaDB Error 1130 (connection refused) and identifying the `'%'` host fix
- Debugging the wp-config.php error caused by a race condition between WordPress and MariaDB startup
- Understanding the healthcheck mechanism and the `touch /tmp/mariadb_ready` pattern

All AI-generated suggestions were reviewed, tested, and understood before being integrated into the project.
