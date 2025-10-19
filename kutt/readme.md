---
source_code: https://github.com/thedevs-network/kutt
tags: ["web apps", "link shortener"]
---

Kutt.it self-hosted via Docker Compose.

- Default web UI: http://localhost:8788
- Change `DEFAULT_DOMAIN`, `DB_*`, `JWT_SECRET`, and adjust ports as needed.
- Persistent data paths:
  - Postgres: `/home/docker/kutt/postgres`
  - Redis: `/home/docker/kutt/redis`

Quick start:

1. Edit `docker-compose.yml` and set a real domain and strong secrets.
2. Create the local data directories:
   - `/home/docker/kutt/postgres`
   - `/home/docker/kutt/redis`
3. Bring it up:
   - `docker compose up -d`

Notes:
- Email (SMTP) variables are optional but recommended for password resets and verifications.
- Admin accounts can be assigned via `ADMIN_EMAILS` (comma separated).
- See upstream docs: https://docs.kutt.it/
