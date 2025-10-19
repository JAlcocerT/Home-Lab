---
source_code: https://github.com/antiwork/gumroad
tags: ["ecommerce"]
---

# Gumroad (antiwork) – Infra stack via Docker Compose

This folder provides the infrastructure services Gumroad uses in development, based on the upstream `docker/docker-compose-local.yml`. It does NOT start the Gumroad Rails app; run the app from the repo on your host and point it to these services.

- Compose file: `gumroad/docker-compose.yml`
- Env example: `gumroad/.env.example`

## Quick start

1) Copy the example env and edit it

```bash
cp .env.example .env
# Set MYSQL_ROOT_PASSWORD to a strong value
```

2) Start the stack

```bash
docker compose --env-file .env up -d
```

3) Services/ports

- MySQL 8.0.32 — `localhost:3306`
- Redis 7.0.7 — `localhost:6379`
- MongoDB 3.6.16 — `localhost:27017`
- Elasticsearch 7.9.3 — `localhost:9200`
- (Optional) Nginx — `80, 443` if you keep the service enabled

If you already have these ports in use, edit the `ports:` mappings in `docker-compose.yml` or remove unneeded services.

## Using with the Gumroad app

- Follow the upstream README to run the Rails app locally.
- Point your app's env variables to these services, for example:
  - `DATABASE_HOST=127.0.0.1`
  - `DATABASE_PORT=3306`
  - `REDIS_URL=redis://127.0.0.1:6379`
  - `MONGO_URL=mongodb://127.0.0.1:27017`
  - `ELASTICSEARCH_URL=http://127.0.0.1:9200`

Note: exact names vary by Gumroad's `.env.*` files.

## Nginx (optional)

The upstream repo includes a local nginx for dev HTTPS/domain routing. If you need it, keep the `nginx` service and provide configs under `gumroad/local-nginx/` (see upstream `docker/local-nginx/`). Otherwise, you can comment out the service.

## Data persistence

Named volumes are used for data:

- `mysql_data` — MySQL data
- `redis_data` — Redis AOF
- `mongo_data` — MongoDB data
- `elasticsearch7data` — Elasticsearch data

Back up by stopping the stack and archiving the Docker volumes.

## Notes

- Versions are pinned to those used upstream for local dev. Newer versions may break compatibility.
- If you run the Rails app in containers instead, prefer the upstream repo's scripts and Dockerfiles.
