# ==============================================================================
# Variables
# ==============================================================================

# Colors
RED=\033[0;31m
GREEN=\033[0;32m
CYAN=\033[0;36m
NC=\033[0m

#Volumes 
WP_DATA=/home/abdallah/data/wp_data
DATABASE=/home/abdallah/data/database

# Paths
COMPOSE_CMD = docker compose -f srcs/docker-compose.yml
# COMPOSE_FILE=srcs/docker-compose.yml

# ==============================================================================
# Help & Default Target
# ==============================================================================

# Set the default action when 'make' is run without arguments.
.DEFAULT_GOAL := help

help: ## Show this detailed help message
	@echo ""
	@echo " \033[1mUsage:\033[0m"
	@echo "   make [TARGET]"
	@echo ""
	@echo " \033[1mProject Management Targets:\033[0m"
	@echo "   \033[0;36mbuild\033[0m                  Builds or rebuilds the Docker images from their Dockerfiles."
	@echo "                          It first ensures host directories for persistent data are created."
	@echo "                          This command is fast on subsequent runs if no files have changed due to Docker's cache."
	@echo ""
	@echo "   \033[0;36mup (or all)\033[0m            Starts all services in detached mode (background). If images are not yet"
	@echo "                          built, this command will trigger 'build' first. This is the primary command to run the project."
	@echo ""
	@echo "   \033[0;36mdown\033[0m                   Stops the running containers and removes the container instances and network."
	@echo "                          It does NOT remove the persistent data stored on the host machine."
	@echo ""
	@echo " \033[1mCleaning Targets:\033[0m"
	@echo "   \033[0;36mclean\033[0m                  A more thorough 'down'. It stops and removes containers, networks, and any"
	@echo "                          named volumes created by Docker Compose. This is the standard way to completely"
	@echo "                          reset the project's Docker state without touching the persistent data."
	@echo ""
	@echo "   \033[0;36mre\033[0m                     A developer's shortcut to 'rebuild'. It fully tears down the project stack"
	@echo "                          (via 'clean') and then starts it again from scratch (via 'up'). Useful for applying"
	@echo "                          changes that require a full reset of the containers."
	@echo ""
	@echo "   \033[0;31mpurge\033[0m                  \033[1m[DESTRUCTIVE]\033[0m The most powerful cleaning command. It performs a 'clean' and then:"
	@echo "                           1. \033[1mPermanently deletes all project data\033[0m from the host machine ($(WP_DATA_PATH), etc)."
	@echo "                           2. \033[1mPrunes the entire Docker system\033[0m, removing ALL stopped containers, unused networks,"
	@echo "                              dangling images, and unused volumes from ANY project on your machine."
	@echo "                          \033[1mUSE WITH EXTREME CAUTION. This action is irreversible.\033[0m"
	@echo ""
	@echo "   \033[0;31mre-fresh\033[0m               \033[1m[DESTRUCTIVE]\033[0m Performs a complete factory reset of the project."
	@echo "                          It runs 'purge' (deleting ALL project data and Docker cache) and then 'up'."
	@echo "                          \033[1mUse this if you want to start from a truly clean slate. All data will be lost.\033[0m"
	@echo ""
# ==============================================================================
# Main Targets
# ==============================================================================
all : up

build:
	@echo "${GREEN}Let's create the needed folders...${NC}"
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DATABASE)
	@echo "${GREEN}Building the Docker containers...${NC}"
	$(COMPOSE_CMD) build

up: build
	$(COMPOSE_CMD) up -d --remove-orphans

down: ## Stop the running services
	@echo "$(GREEN)Stopping Docker containers...$(NC)"
	@$(COMPOSE_CMD) down

# ==============================================================================
# Cleaning Targets
# ==============================================================================

clean: ## Stop services and remove containers, networks, and volumes
	@echo "$(GREEN)Stopping and removing containers and volumes...$(NC)"
	@$(COMPOSE_CMD) down --volumes --remove-orphans

prune: ## Remove unused Docker data
	@docker system prune -a --volumes -f

# remove_volumes:
# 	@docker volume rm $(WP_DATA) || true
# 	@echo "${GREEN}Volume ${WP_DATA} has been removed.${NC}"
# 	@docker volume rm $(DATABASE) || true
# 	@echo "${GREEN}Volume ${DATABASE} has been removed.${NC}"

delete_persistent_data:
	@rm -rf $(WP_DATA) || true
	@rm -rf $(DATABASE) || true


# fclean:
# 	@echo "${RED}Removing containers AND data volumes for this project...${NC}"
# 	@$(COMPOSE_CMD) down --volumes --remove-orphans

purge:
	@echo "${CYAN}This will remove all containers, volumes, and images.${NC}"
	@echo "${CYAN}The building process will take longer than usual and cannot be undone.${NC}"
	@echo "${CYAN}Are you sure? (type 'yes' to confirm):${NC}"
	@read -p "" CONFIRM; \
	if [ "$$CONFIRM" = "yes" ]; then \
		echo "${GREEN}Confirmation received.${NC}"; \
		$(MAKE) clean; \
		echo "$(RED)Pruning all unused Docker containers, networks, volumes, and images...$(NC)"; \
		$(MAKE) prune; \
		echo "$(RED)Deleting persistent data from host at $(WP_DATA_PATH) and $(DB_DATA_PATH)...$(NC)"; \
		$(MAKE) delete_persistent_data; \
		echo "$(GREEN)System purged.$(NC)"; \
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

re-fresh: ## [DESTRUCTIVE] Purge ALL data and caches, then rebuild the project
	@echo "${CYAN}This will remove all containers, volumes, and images.${NC}"
	@echo "${CYAN}The building process will take longer than usual and cannot be undone.${NC}"
	@echo "${CYAN}Are you sure? (type 'yes' to confirm):${NC}"
	@read -p "" CONFIRM; \
	if [ "$$CONFIRM" = "yes" ]; then \
		echo "${GREEN}Confirmation received. Proceeding...${NC}"; \
		$(MAKE) clean; \
		$(MAKE) prune; \
		$(MAKE) delete_persistent_data; \
		$(MAKE) up; \
	else \
		echo "${RED}Operation cancelled.${NC}"; \
	fi

.PHONY: all build up down prune clean help purge re re-fresh