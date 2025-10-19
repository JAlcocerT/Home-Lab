---
source_code: https://github.com/hcengineering/huly-selfhost
tags: ["web apps", "project management", "collaboration"]
---

Huly self-hosted via Docker Compose.

Upstream repos/docs:
- https://github.com/hcengineering/huly-selfhost
- https://docs.huly.io/getting-started/self-host/

Files in this folder:
- `huly/docker-compose.yml` – adapted from upstream `compose.yml` to match this repo conventions (Compose v3, explicit networks/volumes kept).

Prerequisites:
- Docker and Docker Compose
- A domain or host accessible address for `HOST_ADDRESS`

Key environment variables (set in your shell or a local `.env` next to `docker-compose.yml`):
- `HULY_VERSION` – e.g. `v242` (check upstream releases)
- `SECRET` – a strong random string
- `HOST_ADDRESS` – e.g. `192.168.1.11:8087` or your domain
- `HTTP_BIND` – host bind address, e.g. `0.0.0.0`
- `HTTP_PORT` – host HTTP port, e.g. `8087`
- `CR_DATABASE`, `CR_USERNAME`, `CR_USER_PASSWORD` – CockroachDB initial values
- `CR_DB_URL` – e.g. `postgresql://<user>:<pass>@cockroach:26257/<db>?sslmode=disable`
- `REDPANDA_ADMIN_USER`, `REDPANDA_ADMIN_PWD` – Redpanda admin credentials
- Optional GitHub integration variables (see upstream README)

Required config files to fetch from upstream:
- `.huly.nginx` – reverse-proxy config for the `nginx` service.
  - Source: https://raw.githubusercontent.com/hcengineering/huly-selfhost/main/.huly.nginx

Quick start:
1) Create a `.env` file in `huly/` with the variables above. Example minimal values:
   ```env
   HULY_VERSION=v242
   SECRET=change_me_strong
   HOST_ADDRESS=192.168.1.11:8087
   HTTP_BIND=0.0.0.0
   HTTP_PORT=8087
   CR_DATABASE=huly
   CR_USERNAME=huly
   CR_USER_PASSWORD=change_me_db
   CR_DB_URL=postgresql://huly:change_me_db@cockroach:26257/huly?sslmode=disable
   REDPANDA_ADMIN_USER=admin
   REDPANDA_ADMIN_PWD=change_me_rp
   ```
2) Download Nginx config next to the compose:
   ```sh
   wget -O .huly.nginx https://raw.githubusercontent.com/hcengineering/huly-selfhost/main/.huly.nginx
   ```
3) Bring up the stack:
   ```sh
   docker compose up -d
   ```
4) Browse the UI via Nginx on `http://<HOST_ADDRESS>` (e.g. `http://192.168.1.11:8087`).

Notes:
- The compose includes `cockroach` (DB), `redpanda` (queue), `minio` (object storage), `elastic` (search), plus Huly services (`front`, `account`, `workspace`, `transactor`, `collaborator`, `fulltext`, `rekoni`, `stats`, `kvs`).
- Volumes are defined as named volumes unless you set custom host paths via `VOLUME_*` env vars.
- For GitHub integration, follow the upstream README section “GitHub Integration” and add the suggested `github` service + env vars, plus Nginx route updates.
- For production, secure your reverse proxy, use strong secrets, and move off default credentials.