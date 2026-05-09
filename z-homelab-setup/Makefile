.DEFAULT_GOAL := help

COMPOSE_DIR  := evolution
COMPOSE_FILE ?= 2604_docker-compose.yml

.PHONY: help bootstrap setup env up down logs ps pull

help: ## Show available targets
	@printf "\nUsage: make <target> [COMPOSE_FILE=filename]\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@printf "\nCompose files in $(COMPOSE_DIR)/:\n"
	@ls $(COMPOSE_DIR)/*docker-compose*.yml 2>/dev/null | xargs -n1 basename | sed 's/^/  /'
	@printf "\nDefault COMPOSE_FILE: $(COMPOSE_FILE)\n\n"

bootstrap: ## Full first-run: setup → env → up (in order)
	@$(MAKE) setup
	@$(MAKE) env
	@$(MAKE) up

setup: ## Run homelab-selfhosting.sh (requires root)
	sudo bash homelab-selfhosting.sh

env: ## Generate .env from .env.sample inside evolution/
	cd $(COMPOSE_DIR) && bash setup-env.sh

up: ## Start containers  [COMPOSE_FILE=2604_docker-compose.yml]
	docker compose -f $(COMPOSE_DIR)/$(COMPOSE_FILE) up -d

down: ## Stop containers  [COMPOSE_FILE=2604_docker-compose.yml]
	docker compose -f $(COMPOSE_DIR)/$(COMPOSE_FILE) down

logs: ## Follow logs  [COMPOSE_FILE=2604_docker-compose.yml]
	docker compose -f $(COMPOSE_DIR)/$(COMPOSE_FILE) logs -f

ps: ## Show running containers  [COMPOSE_FILE=2604_docker-compose.yml]
	docker compose -f $(COMPOSE_DIR)/$(COMPOSE_FILE) ps

pull: ## Pull latest images  [COMPOSE_FILE=2604_docker-compose.yml]
	docker compose -f $(COMPOSE_DIR)/$(COMPOSE_FILE) pull
