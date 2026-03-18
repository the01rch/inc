# Developer Documentation - Inception Project

## 1. System Architecture
The infrastructure is designed as a set of microservices orchestrated by Docker Compose. Each service is isolated in its own container to ensure a modular and secure environment.

###  Network Schema
- **inception_frontend**: A bridge network that connects all three containers. 
- **Isolation**: Only the NGINX container exposes a port (443) to the host machine. MariaDB and WordPress communicate internally via the Docker DNS (service names).

###  Storage & Persistence
Two local volumes are defined to ensure data persists even if containers are deleted:
- `mariadb_volume` -> Bind mounted to `/home/redrouic/data/mariadb`
- `wordpress_volume` -> Bind mounted to `/home/redrouic/data/wordpress`

## 2. Service Details

###  NGINX (The Entry Point)
- **Base Image**: Debian Bullseye.
- **Protocol**: Exclusively TLS v1.2 and v1.3 as required.
- **Role**: It acts as a reverse proxy. It serves static files directly and forwards PHP requests to the WordPress container via the **FastCGI** protocol on port 9000.
- **SSL**: A self-signed certificate is generated during the build process for `redrouic.42.fr`.

###  MariaDB (The Database)
- **Configuration**: Uses a custom `50-server.cnf` to allow connections from other containers (`bind-address = *`).
- **Initialization**: The `init.sh` script handles the creation of the root password, the WordPress database, and the regular user. 
- **Healthcheck**: Implements a check using `mysqladmin ping` to ensure the service is ready before WordPress starts its setup.

###  WordPress + PHP-FPM
- **Base Image**: Debian Bullseye with PHP 7.4-FPM.
- **Automation**: Uses `wp-cli` to download, install, and configure WordPress automatically if it's not already present in the volume.
- **Process Management**: PHP-FPM is configured to run in the foreground (`-F`) to keep the container active.

## 3. Security & Best Practices

- **PID 1 & Signals**: All entrypoint scripts use the `exec` command to start the final service. This allows the service (mysqld, nginx, or php-fpm) to become PID 1 and correctly handle termination signals (SIGTERM/SIGQUIT).
- **Non-Root usage**: NGINX and WordPress processes run under the `www-data` user to minimize security risks.
- **No Hacks**: No infinite loops (like `tail -f /dev/null`) are used. Containers stay alive because the main service runs in the foreground.

## 4. Environment Variables
All sensitive data (passwords, logins, DB names) are managed through a `.env` file located in the `srcs/` directory. This file is excluded from version control for security reasons.
