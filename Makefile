# Colors
RED=\033[0;31m
GREEN=\033[0;32m
NC=\033[0m

all : up

build:
	docker compose -f srcs/docker-compose.yml build

up: build
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

prune: 
	@docker system prune -a --volumes -f

clean: down prune
	@echo "${GREEN}All containers and volumes have been removed.${NC}"

re: clean up

.PHONY: all build up down prune clean