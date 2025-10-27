---
tags: "Monitoring"
source_code: https://github.com/mostafawahied/portracker
---

# Portracker

Portracker is a tool for tracking and managing Docker container ports and services.

## Quick Start

1. Create a directory for persistent data:
   ```bash
   mkdir -p portracker-data
   ```

2. Create a `docker-compose.yml` file with the following content:


3. Start the service:
   ```bash
   docker-compose up -d
   ```

## Access

Access the Portracker web interface at: `http://your-server-ip:4999`

## Features

- Track Docker container ports and services
- Web-based interface for easy management
- Persistent data storage
- TrueNAS integration (optional)

## Volumes

- `./portracker-data:/data`: Stores the SQLite database and configuration
- `/var/run/docker.sock`: Required for Docker API access

## Environment Variables

- `DATABASE_PATH`: Path to the SQLite database file (default: `/data/portracker.db`)
- `PORT`: Port to run the web interface on (default: `4999`)
- `TRUENAS_API_KEY`: (Optional) API key for TrueNAS integration
