# Default make goal
.DEFAULT_GOAL := help

# Auto-load variables from .env if present (PB_ADMIN_EMAIL, PB_ADMIN_PASSWORD, PB_URL, EMAIL, PASSWORD, USERNAME, ...)
ifneq (,$(wildcard .env))
include .env
# Export all keys from .env to the environment for subprocesses
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' .env)
endif

.PHONY: local-install
local-install: ## Install dependencies using npm (runs: npm install)
	npm install

.PHONY: local-build
local-build: ## Build the project using npm (runs: npm run build)
	npm run build

.PHONY: local-dev
local-dev: ## Start the dev server using npm (runs: npm run dev)
	npm run dev -- --host 0.0.0.0 --port 4321

.PHONY: web-containers-up
web-containers-up: ## Start dev server on http://localhost:4321 using docker-compose-ssg.yml
	docker compose -f docker-compose-ssg.yml up -d

.PHONY: web-containers-down
web-containers-down: ## Stop dev server on http://localhost:4321 using docker-compose-ssg.yml
	docker compose -f docker-compose-ssg.yml down

.PHONY: stack-down
stack-down: ## Stop PocketBase, Flask, and Astro dev using docker-compose.yml
	docker compose -f docker-compose.yml down

.PHONY: stack-logs
stack-logs: ## Tail logs for PocketBase, Flask, and Astro dev
	docker compose -f docker-compose.yml logs -f pocketbase flask-cms astro-dev

.PHONY: web-prod-up
web-prod-up: ## Start ONLY Astro production from main docker-compose.yml (detached)
	docker compose -f docker-compose.yml up -d --build astro-prod

.PHONY: web-prod-down
web-prod-down: ## Stop ONLY Astro production from main docker-compose.yml
	docker compose -f docker-compose.yml down --remove-orphans

.PHONY: web-prod-logs
web-prod-logs: ## Tail Astro production logs from main docker-compose.yml
	docker compose -f docker-compose.yml logs -f astro-prod

.PHONY: ssg-prod-up
ssg-prod-up: ## (Alt) Start ONLY Astro production using docker-compose-ssg.yml (detached)
	docker compose -f docker-compose-ssg.yml up -d --build astro-prod

.PHONY: ssg-prod-down
ssg-prod-down: ## (Alt) Stop ONLY Astro production using docker-compose-ssg.yml
	docker compose -f docker-compose-ssg.yml down --remove-orphans

.PHONY: ssg-prod-logs
ssg-prod-logs: ## (Alt) Tail Astro production logs using docker-compose-ssg.yml
	docker compose -f docker-compose-ssg.yml logs -f astro-prod

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"}; /^[a-zA-Z0-9_.-]+:.*?##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)