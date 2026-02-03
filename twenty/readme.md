---
source_code: https://github.com/twentyhq/twenty
tags: ["CRM","OSS for business"]
---


---

# Twenty (twentyhq) – Self-hosted via Docker Compose

This folder contains a ready-to-run Docker Compose setup for [Twenty](https://github.com/twentyhq/twenty).

- Compose file: `twenty/docker-compose.yml`
- Env example: `twenty/.env.example`

## Quick start

1) Copy the example env and edit it

```bash
cp .env.example .env
# Edit .env and set:
# - PG_DATABASE_PASSWORD (no special characters)
# - SERVER_URL (e.g. http://<your-ip>:3000 or https://your.domain)
# - APP_SECRET (use: openssl rand -base64 32)
```

2) Start the stack

```bash
docker compose --env-file .env up -d
```

3) Access the app

- Direct: http://localhost:3000
- Remote: http://<server-ip>:3000 or your reverse-proxied domain

## Services

- `server`: Twenty application HTTP server (port 3000)
- `worker`: background jobs/queues
- `db`: Postgres 16 with persistent volume `db-data`
- `redis`: Redis for queues and cache

## Volumes & persistence

- `db-data`: Postgres data
- `server-local-data`: Internal server storage (attachments if `STORAGE_TYPE=local`)

Back up by stopping the stack and archiving the Docker volumes or bind mounts.

## Reverse proxy

Run behind your preferred reverse proxy (e.g., Traefik/Ngininx). Ensure:

- `SERVER_URL` in `.env` matches the public URL (https strongly recommended)
- Proxy forwards to container `server:3000`

## Upgrades

To upgrade to the latest stable image:

```bash
docker compose pull
docker compose up -d
```

If you pin `TAG` in `.env`, set it to a specific version and re-run the above.

## Troubleshooting

- Ensure at least 2 GB RAM.
- If the server is unhealthy, check logs:

```bash
docker compose logs -f server worker db redis
```

- Verify `PG_DATABASE_PASSWORD` has no special characters.
- Verify `APP_SECRET` is set to a long random base64 string.
- Verify `SERVER_URL` reflects how you access the app.
