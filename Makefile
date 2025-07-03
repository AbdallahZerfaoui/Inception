# ==============================================================================
# Variables
# ==============================================================================

# Colors
RED=\033[0;31m
GREEN=\033[0;32m
CYAN=\033[0;36m
NC=\033[0m

#Volumes 
WP_DATA=/home/azerfaou/data/wp_data
DATABASE=/home/azerfaou/data/database

# Paths
COMPOSE_CMD = docker compose -f srcs/docker-compose.yml

# Others
s ?= wordpress

# ==============================================================================
# Help & Default Target
# ==============================================================================

# Set the default action when 'make' is run without arguments.
.DEFAULT_GOAL := help

help: ## Show this detailed help message
	@echo ""
	@echo " \033[1mUsage:\033[0m"
	@echo "   make [TARGET]"
	@echo "   make logs/bash s=<service_name>"
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
	@echo "   \033[0;36mrestart\033[0m                Stops and then restarts all services."
	@echo "                          Perfect for applying configuration changes from docker-compose.yml without a full rebuild."
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
	@echo " \033[1mDebugging & Interaction Targets:\033[0m"
	@echo "   \033[0;36mlogs\033[0m                   Follow the real-time logs of a running service."
	@echo "                          You can specify which service's logs to view."
	@echo "                          \033[1mUsage:\033[0m make logs s=<service_name>  \033[2m(e.g., make logs s=mariadb)\033[0m"
	@echo "                          \033[2m(Defaults to 'wordpress' if 's' is not provided)\033[0m"
	@echo ""
	@echo "   \033[0;36mbash\033[0m                  Access an interactive bash shell inside a running service."
	@echo "                          This is essential for debugging, running commands, or inspecting files."
	@echo "                          \033[1mUsage:\033[0m make bash s=<service_name> \033[2m(e.g., make bash s=nginx)\033[0m"
	@echo "                          \033[2m(Defaults to 'wordpress' if 's' is not provided)\033[0m"
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

delete_persistent_data:
	@rm -rf $(WP_DATA) || true
	@rm -rf $(DATABASE) || true

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

restart: ## Stop and restart the services to apply compose file changes
	@$(MAKE) down
	@$(MAKE) up

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

# ==============================================================================
# Debugging & Interaction Targets
# ==============================================================================
logs: ## Show logs for all services
	@echo "$(CYAN)Displaying logs for service $(s)...$(NC)"
	@$(COMPOSE_CMD) logs -f $(s)

bash: ## Open a bash in the specified service container
	@echo "$(CYAN)Opening a bash in the $(s) container...$(NC)"
	@$(COMPOSE_CMD) exec -it $(s) bash

# art:
# 	@echo "IIIIIIIIIINNNNNNNN        NNNNNNNN        CCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEEPPPPPPPPPPPPPPPPP   TTTTTTTTTTTTTTTTTTTTTTTIIIIIIIIII     OOOOOOOOO     NNNNNNNN        NNNNNNNN"
# 	@echo "I::::::::IN:::::::N       N::::::N     CCC::::::::::::CE::::::::::::::::::::EP::::::::::::::::P  T:::::::::::::::::::::TI::::::::I   OO:::::::::OO   N:::::::N       N::::::N"
# 	@echo "I::::::::IN::::::::N      N::::::N   CC:::::::::::::::CE::::::::::::::::::::EP::::::PPPPPP:::::P T:::::::::::::::::::::TI::::::::I OO:::::::::::::OO N::::::::N      N::::::N"
# 	@echo "II::::::IIN:::::::::N     N::::::N  C:::::CCCCCCCC::::CEE::::::EEEEEEEEE::::EPP:::::P     P:::::PT:::::TT:::::::TT:::::TII::::::IIO:::::::OOO:::::::ON:::::::::N     N::::::N"
# 	@echo "  I::::I  N::::::::::N    N::::::N C:::::C       CCCCCC  E:::::E       EEEEEE  P::::P     P:::::PTTTTTT  T:::::T  TTTTTT  I::::I  O::::::O   O::::::ON::::::::::N    N::::::N"
# 	@echo "  I::::I  N:::::::::::N   N::::::NC:::::C                E:::::E               P::::P     P:::::P        T:::::T          I::::I  O:::::O     O:::::ON:::::::::::N   N::::::N"
# 	@echo "  I::::I  N:::::::N::::N  N::::::NC:::::C                E::::::EEEEEEEEEE     P::::PPPPPP:::::P         T:::::T          I::::I  O:::::O     O:::::ON:::::::N::::N  N::::::N"
# 	@echo "  I::::I  N::::::N N::::N N::::::NC:::::C                E:::::::::::::::E     P:::::::::::::PP          T:::::T          I::::I  O:::::O     O:::::ON::::::N N::::N N::::::N"
# 	@echo "  I::::I  N::::::N  N::::N:::::::NC:::::C                E:::::::::::::::E     P::::PPPPPPPPP            T:::::T          I::::I  O:::::O     O:::::ON::::::N  N::::N:::::::N"
# 	@echo "  I::::I  N::::::N   N:::::::::::NC:::::C                E::::::EEEEEEEEEE     P::::P                    T:::::T          I::::I  O:::::O     O:::::ON::::::N   N:::::::::::N"
# 	@echo "  I::::I  N::::::N    N::::::::::NC:::::C                E:::::E               P::::P                    T:::::T          I::::I  O:::::O     O:::::ON::::::N    N::::::::::N "
# 	@echo "  I::::I  N::::::N     N:::::::::N C:::::C       CCCCCC  E:::::E       EEEEEE  P::::P                    T:::::T          I::::I  O::::::O   O::::::ON::::::N     N:::::::::N"
# 	@echo "II::::::IIN::::::N      N::::::::N  C:::::CCCCCCCC::::CEE::::::EEEEEEEE:::::EPP::::::PP                TT:::::::TT      II::::::IIO:::::::OOO:::::::ON::::::N      N::::::::N"
# 	@echo "I::::::::IN::::::N       N:::::::N   CC:::::::::::::::CE::::::::::::::::::::EP::::::::P                T:::::::::T      I::::::::I OO:::::::::::::OO N::::::N       N:::::::N"
# 	@echo "I::::::::IN::::::N        N::::::N     CCC::::::::::::CE::::::::::::::::::::EP::::::::P                T:::::::::T      I::::::::I   OO:::::::::OO   N::::::N        N::::::N"
# 	@echo "IIIIIIIIIINNNNNNNN         NNNNNNN        CCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEEPPPPPPPPPP                TTTTTTTTTTT      IIIIIIIIII     OOOOOOOOO     NNNNNNNN         NNNNNNN"

.PHONY: all build up down prune clean help purge re re-fresh