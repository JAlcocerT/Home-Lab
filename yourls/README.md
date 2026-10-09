# YOURLS

Self-hosted URL shortener with the official YOURLS Apache image and MariaDB.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
docker compose up -d
```

Set `YOURLS_PASS`, `MARIADB_ROOT_PASSWORD`, and `MARIADB_PASSWORD` before starting.

Default local URL:

```text
http://localhost:8789/admin/
```

`YOURLS_SITE` must match the public URL without a trailing slash.

Examples:

```env
YOURLS_SITE=http://192.168.1.2:8789
YOURLS_SITE=https://s.example.com
```

For public use, put YOURLS behind HTTPS with a reverse proxy and set `YOURLS_SITE` to the HTTPS URL.
