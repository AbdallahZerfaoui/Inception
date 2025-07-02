# Colors
RED=\033[0;31m
GREEN=\033[0;32m
CYAN=\033[0;36m
NC=\033[0m

#Volumes 
WP_DATA=/home/abdallah/data/wp_data
DATABASE=/home/abdallah/data/database

# Paths
COMPOSE_FILE=srcs/docker-compose.yml


all : up

build:
	@echo "${GREEN}Let's create the needed folders...${NC}"
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DATABASE)
	@echo "${GREEN}Building the Docker containers...${NC}"
	docker compose -f srcs/docker-compose.yml build

up: build
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

# deep_down:
# 	docker compose -f srcs/docker-compose.yml down --volumes

prune: 
	@docker system prune -a --volumes -f

remove_volumes:
	@docker volume rm $(WP_DATA) || true
	@echo "${GREEN}Volume ${WP_DATA} has been removed.${NC}"
	@docker volume rm $(DATABASE) || true
	@echo "${GREEN}Volume ${DATABASE} has been removed.${NC}"

clean: down prune remove_volumes
	@echo "${GREEN}All containers and volumes have been removed.${NC}"

fclean:
	@echo "${RED}Removing containers AND data volumes for this project...${NC}"
	@docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans

purge:
	@echo "${CYAN}This will remove all containers, volumes, and images.${NC}"
	@echo "${CYAN}The building process will take longer than usual and cannot be undone.${NC}"
	@echo "${CYAN}Are you sure? (type 'yes' to confirm):${NC}"
	@read -p "" CONFIRM; \
	if [ "$$CONFIRM" = "yes" ]; then \
		echo "${GREEN}Confirmation received. Proceeding...${NC}"; \
		$(MAKE) fclean; \
		$(MAKE) prune; \
	else \
		echo "${RED}Operation cancelled.${NC}"; \
	fi

re:
	@echo "${CYAN}This will remove all containers, volumes, and images.${NC}"
	@echo "${CYAN}The building process will take longer than usual and cannot be undone.${NC}"
	@echo "${CYAN}Are you sure? (type 'yes' to confirm):${NC}"
	@read -p "" CONFIRM; \
	if [ "$$CONFIRM" = "yes" ]; then \
		echo "${GREEN}Confirmation received. Proceeding...${NC}"; \
		$(MAKE) clean; \
		$(MAKE) up; \
	else \
		echo "${RED}Operation cancelled.${NC}"; \
	fi

.PHONY: all build up down prune clean fclean deep_down remove_volumes