# Kaunta

Self-hosted privacy-first web analytics with a Rust server, PostgreSQL, browser tracker, CSV export, goals, map, realtime feed, and optional MCP tools.

## Start

```bash
cp .env.sample .env
openssl rand -hex 16
```

Put the generated alphanumeric value in `POSTGRES_PASSWORD`, then run:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

Open the setup wizard:

```text
http://192.168.1.2:3823/setup
```

The wizard checks PostgreSQL 18, applies migrations, creates the first administrator, writes configuration, and continues to the dashboard. There is no default Kaunta user/password. The database and application state are stored in named volumes.
