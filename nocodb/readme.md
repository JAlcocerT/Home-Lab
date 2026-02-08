---
source_code: https://github.com/nocodb/nocodb
post: https://nocodb.com/docs/self-hosting/installation/docker-compose
tags: ["Database", "No-code","CRM"]
---

Bring projects, wikis, and teams together with AI

# NocoDB Self-Hosting

This folder contains the Docker Compose configuration to self-host NocoDB.

You can consider it an API heavy database with a web interface that can become your CRM.

## Setup and Deployment

### 1. Clone the NocoDB Repository (Alternative)

If you prefer to use the official source:

```bash
git clone https://github.com/nocodb/nocodb
cd nocodb/docker-compose/2_pg
```

### 2. Start the Services

Run the services via Docker Compose in the background:

```bash
docker compose up -d
```

### 3. Access NocoDB
Access NocoDB in your browser by visiting: `http://localhost:8080`

### 4. Verify the Deployment

Check if all services are running and healthy:

```bash
docker compose ps
```

## Resources and Documentation

* [NocoDB Docker Compose Documentation](https://nocodb.com/docs/self-hosting/installation/docker-compose)
* [NocoDB GitHub](https://github.com/nocodb/nocodb)

## Troubleshooting

* Check the logs: `docker compose logs`
* Stop the services: `docker compose down`