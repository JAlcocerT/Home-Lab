# Supabase Home-Lab Notes

This folder mirrors the official Supabase self-hosted Docker directory from:

```text
self-hosted/v0.8.2
```

The full stack is intentionally kept close to upstream because self-hosted
Supabase is not a small single-compose app. The compose file depends on the
scripts, volumes, Envoy configuration, SQL initialization files, and optional
override files in this directory.

## Before First Start

Do not run the stack with `.env.example` unchanged.

Prepare it with:

```bash
cp .env.example .env
sh utils/generate-keys.sh
sh utils/add-new-auth-keys.sh
```

Then edit `.env` and review at least:

- `POSTGRES_PASSWORD`
- `JWT_SECRET`
- `ANON_KEY`
- `SERVICE_ROLE_KEY`
- `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SECRET_KEY`
- `DASHBOARD_USERNAME`
- `DASHBOARD_PASSWORD`
- `SECRET_KEY_BASE`
- `REALTIME_DB_ENC_KEY`
- `VAULT_ENC_KEY`
- `PG_META_CRYPTO_KEY`
- `LOGFLARE_PUBLIC_ACCESS_TOKEN`
- `LOGFLARE_PRIVATE_ACCESS_TOKEN`
- `S3_PROTOCOL_ACCESS_KEY_ID`
- `S3_PROTOCOL_ACCESS_KEY_SECRET`
- `SUPABASE_PUBLIC_URL`
- `API_EXTERNAL_URL`
- `SITE_URL`

Start with:

```bash
sh run.sh start
```

Inspect active compose files:

```bash
sh run.sh config
```

Validate without starting:

```bash
docker compose --env-file .env.example config
```

## Optional Overrides

Supabase uses override files managed through `run.sh`:

```bash
sh run.sh config add logs
sh run.sh config add caddy
sh run.sh config add nginx
sh run.sh config add rustfs
sh run.sh config add pgbouncer
```

Current upstream deprecations to keep in mind:

- Kong is now optional; Envoy is the default API gateway.
- MinIO S3 override is planned for removal in favor of RustFS.
- Postgres 15 override is legacy because Postgres 17 is the default.

## Update Flow

Back up first, then use the upstream updater:

```bash
sh update.sh --dry-run
sh update.sh
sh run.sh pull
sh run.sh recreate
```

This folder includes `.supabase-version` so `update.sh` can understand the
base self-hosted release.
