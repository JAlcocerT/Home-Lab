---
source_code: https://github.com/Donkie/Spoolman
tags: ["3D printing", "filament", "inventory", "FastAPI", "self-hosting"]
---

# Spoolman

Self-hosted filament spool inventory for 3D printing.

```bash
cp .env.sample .env
docker compose up -d
```

Local URL:

```text
http://192.168.1.2:3822/
```

Health check:

```bash
curl http://127.0.0.1:3822/api/v1/health
```

This compose uses Spoolman's built-in SQLite mode and stores the database,
backups, cache, and logs in `./data`.

The `.env` file is read by Docker Compose for variable interpolation. Only the
explicit runtime variables in `docker-compose.yml` are passed into the
container.

There is no default login because Spoolman has no built-in authentication by
design. Keep it on a trusted LAN/VPN or put it behind a reverse proxy with
authentication before exposing it outside the homelab.

Do not set `SPOOLMAN_PORT` in `.env` to the public host port. In the Docker
image that variable changes the app's internal listener. Use
`SPOOLMAN_HTTP_PORT` for the host port instead.
