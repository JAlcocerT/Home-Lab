# Endurain

Self-hosted fitness tracking with a Vue frontend, FastAPI backend, and PostgreSQL database.

## Start

```sh
cp .env.sample .env
openssl rand -hex 32
openssl rand -base64 32
# Put generated values in SECRET_KEY and FERNET_KEY, and replace both passwords.
docker compose config
docker compose up -d
```

Open `http://localhost:3850`. The first account is created through the signup flow; the upstream demo credentials (`admin` / `admin`) are not a safe local default. Set a strong `ENDURAIN_HOST` when using a LAN address or reverse proxy.

The profile uses Endurain's `local` deployment mode, so Redis and S3 are not required. For multiple API workers or multi-node deployments, use the upstream distributed configuration with Redis and S3-compatible object storage.

## Storage and updates

The profile uses named volumes for activity files, user/server images, logs, and PostgreSQL data. Back up `homelab_endurain_data`, `homelab_endurain_logs`, and `homelab_endurain_postgres` before updates. The image is pinned by digest in the compose file; update it deliberately after checking the upstream release and migrations. If you prefer bind mounts, follow the upstream UID 1000 directory ownership instructions.

UI: `http://localhost:3850`
