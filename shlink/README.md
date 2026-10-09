# Shlink

Self-hosted URL shortener with Shlink backend, MariaDB, and optional Shlink Web Client.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
docker compose up -d
```

Set `MARIADB_ROOT_PASSWORD` and `MARIADB_PASSWORD` before starting.

Default local URLs:

```text
http://localhost:8987  Shlink API and redirect backend
http://localhost:8988  Shlink Web Client
```

`DEFAULT_DOMAIN` must be the public short-link hostname without `http://` or `https://`.

Examples:

```env
DEFAULT_DOMAIN=192.168.1.2:8987
DEFAULT_DOMAIN=s.example.com
IS_HTTPS_ENABLED=true
```

GeoLite2 geolocation is skipped by default. To enable geolocation, set `SKIP_INITIAL_GEOLITE_DOWNLOAD=false` and provide `GEOLITE_LICENSE_KEY`.

To create an initial API key at first boot, set `SHLINK_INITIAL_API_KEY` in `.env`. Treat that key as a secret.
