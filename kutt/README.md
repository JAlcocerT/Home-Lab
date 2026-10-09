# Kutt

Self-hosted URL shortener using Kutt with Postgres and Redis.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
docker compose up -d
```

Set `POSTGRES_PASSWORD` and `JWT_SECRET` before starting.

The default local URL is:

```text
http://localhost:8788
```

For LAN or public access, update `DEFAULT_DOMAIN` in `.env` to the hostname users will open in the browser, without `http://` or `https://`.

Examples:

```env
DEFAULT_DOMAIN=192.168.1.2:8788
DEFAULT_DOMAIN=links.example.com
```

Kutt creates the initial admin account through the web UI on first start.
