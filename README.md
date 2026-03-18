This project has been created as part of the 42 curriculum by redrouic.

# Inception - 42 Project

This project consists of virtualizing a small infrastructure of several services using Docker Compose. 
The infrastructure includes:
- A Docker container with **NGINX** (TLS v1.2/v1.3 only).
- A Docker container with **WordPress** + **php-fpm**.
- A Docker container with **MariaDB**.
- Two volumes for database and website file persistence.
- A custom virtual network for container communication.

## How to use
1. Clone the repository.
2. Create a `.env` file in the `srcs/` folder (see `USER_DOC.md`).
3. Run `make` at the root of the project.
4. Access `https://redrouic.42.fr` in your browser.
