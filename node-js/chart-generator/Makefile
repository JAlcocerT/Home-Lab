# Makefile for ApexCharts Generator

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  run           - Run the application directly with Node.js"
	@echo "  debug         - Run the application in DEBUG mode with verbose logging"
	@echo "  dev           - Run the application in development mode (auto-restart on changes)"
	@echo "  test          - Test the health endpoint"
	@echo "  troubleshoot  - Run diagnostic checks to identify issues"
	@echo "  docker-build  - Build the Docker image"
	@echo "  docker-run    - Run the application in a Docker container"
	@echo "  docker-debug  - Run the application in Docker with DEBUG mode"
	@echo "  docker-up     - Build and run with Docker Compose"
	@echo "  docker-down   - Stop and remove the Docker container"

# Run the application directly with Node.js
.PHONY: run
run:
	node server.js

# Run in DEBUG mode with verbose logging
.PHONY: debug
debug:
	DEBUG=true LOG_LEVEL=debug node server.js

# Run in development mode (requires nodemon: npm install -g nodemon)
.PHONY: dev
dev:
	@command -v nodemon >/dev/null 2>&1 || { echo "nodemon not found. Install with: npm install -g nodemon"; exit 1; }
	DEBUG=true NODE_ENV=development nodemon server.js

# Test the health endpoint
.PHONY: test
test:
	@echo "Testing health endpoint..."
	@curl -s http://localhost:3001/health | json_pp || curl -s http://localhost:3001/health

# Run troubleshooting diagnostics
.PHONY: troubleshoot
troubleshoot:
	@./troubleshoot.sh

# Build the Docker image
.PHONY: docker-build
docker-build:
	docker-compose build

# Run the application in a Docker container
.PHONY: docker-run
docker-run:
	docker-compose up -d

# Build and run with Docker Compose
.PHONY: docker-up
docker-up:
	docker-compose up --build -d

# Run Docker container in DEBUG mode
.PHONY: docker-debug
docker-debug:
	DEBUG=true LOG_LEVEL=debug docker-compose up --build

# Stop and remove the Docker container
.PHONY: docker-down
docker-down:
	docker-compose down

# Show logs
.PHONY: logs
logs:
	docker-compose logs -f

# Show logs with timestamps
.PHONY: logs-debug
logs-debug:
	docker-compose logs -f --timestamps

# Clean up Docker resources
.PHONY: clean
clean: docker-down
	@echo "Stopped and removed containers"
