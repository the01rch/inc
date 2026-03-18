# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: redrouic <redrouic@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/16 09:16:28 by redrouic          #+#    #+#              #
#    Updated: 2026/03/18 12:12:59 by redrouic         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

LOGIN		=	redrouic
PATH_DATA	=	/home/$(LOGIN)/data

all: 
	mkdir -p $(PATH_DATA)
	mkdir -p $(PATH_DATA)/mariadb
	mkdir -p $(PATH_DATA)/wordpress
	docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f ./srcs/docker-compose.yml down

stop:
	docker compose -f ./srcs/docker-compose.yml stop

start:
	docker compose -f ./srcs/docker-compose.yml restart

clean: down

fclean: clean
	docker compose -f ./srcs/docker-compose.yml down -v
	@rm -rf $(PATH_DATA)
	docker system prune -af

re: fclean all

ls:
	docker image ls
	docker container ls
	docker volume ls
	docker network ls

logs:
	docker logs my_wordpress_container
	docker logs my_mariadb_container
	docker logs my_nginx_container

.Phony: all down clean fclean re logs ls
