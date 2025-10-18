# Makefile for ApexCharts Generator

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  run           - Run the application directly with Node.js"
	@echo "  docker-build  - Build the Docker image"
	@echo "  docker-run    - Run the application in a Docker container"
	@echo "  docker-up     - Build and run with Docker Compose"
	@echo "  docker-down   - Stop and remove the Docker container"

# Run the application directly with Node.js
.PHONY: run
run:
	node server.js

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

# Stop and remove the Docker container
.PHONY: docker-down
docker-down:
	docker-compose down

# Show logs
.PHONY: logs
logs:
	docker-compose logs -f

# Clean up Docker resources
.PHONY: clean
clean: docker-down
	@echo "Stopped and removed containers"
