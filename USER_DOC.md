# User Documentation - Inception

## Prerequisites
- Docker and Docker Compose must be installed on the host machine.
- Your user must belong to the `docker` group.

## Installation Steps
1. **Configure the Environment Variables**:
   Create a `.env` file inside the `srcs/` directory with the following variables:
   ```env
   DOMAIN_NAME=redrouic.42.fr
   MYSQL_DATABASE=inception
   MYSQL_ROOT_PASSWORD=your_root_password
   ADMIN_USER=redrouic
   ADMIN_PASSWORD=your_admin_password
   ADMIN_MAIL=redrouic@student.42.fr
   USER1_LOGIN=guest
   USER1_PASSWORD=guest_password
   USER1_MAIL=guest@example.com
   SITE_TITLE=Inception_Project
