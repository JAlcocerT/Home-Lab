---
source_code: https://github.com/TheSpaghettiDetective/obico-server
tags: ["3d printing", "octoprint", "klipper", "ai", "self-hosting"]
---

# Obico Server

Self-hosted Obico Server for OctoPrint/Klipper monitoring, remote access, and
AI print-failure detection.

This Home-Lab compose uses the upstream prebuilt GHCR images instead of building
the full server and ML images from source on every deploy.

```bash
cp .env.sample .env
openssl rand -base64 48
```

Put the generated value in `DJANGO_SECRET_KEY`, then start:

```bash
docker compose up -d
```

Local URL:

```text
http://192.168.1.2:3334/
```

Health check:

```bash
curl http://127.0.0.1:3334/hc/
```

Initial Django admin:

```text
URL: http://192.168.1.2:3334/admin/
user: root@example.com
password: supersecret
```

Change that password immediately, then configure the Django Site domain at:

```text
http://192.168.1.2:3334/admin/sites/site/1/change/
```

Use `192.168.1.2:3334` for LAN access, without `http://` and without a trailing
slash. If using a reverse proxy or Cloudflare Tunnel, set the proxy hostname
there and update `SITE_USES_HTTPS` plus `CSRF_TRUSTED_ORIGINS` in `.env`.

Persistent folders:

- `data/` stores SQLite state and Celery schedule data.
- `media/` stores uploaded printer media, timelapses, snapshots, and related files.
- `static/` stores collected Django/static frontend assets.
- `redis/` stores Redis persistence.

SQLite is fine for a small local trial. For a farm or public instance, move
`DATABASE_URL` to PostgreSQL and configure a real SMTP provider for account
emails and alerts.
