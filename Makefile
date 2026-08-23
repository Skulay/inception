NAME = inception

all: up

up:
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

stop:
	docker compose -f srcs/docker-compose.yml stop

start:
	docker compose -f srcs/docker-compose.yml start

restart: down up

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf /home/alehamad/data/wordpress/*
	sudo rm -rf /home/alehamad/data/mariadb/*

re: fclean all

.PHONY: all up down stop start restart clean fclean re