---
source_code: https://github.com/medusajs/medusa
tags: ["ecommerce", "medusa", "node"]
---

# MedusaJS – Backend with Docker Compose

This folder provides a local Medusa stack (backend-only) with Postgres and Redis.

- Compose: `medusajs/docker-compose.yml`
- Env example: `medusajs/.env.example`
- Docker image: `medusajs/Dockerfile`
- Entrypoint: `medusajs/start.sh`

## Requirements

- Docker + Docker Compose
- You will mount a Medusa app into `medusajs/app/` (host) which appears as `/server` (container).

## Quick start (localhost or LAN 192.168.1.11)

1) Create env

```bash
cp .env.example .env
```

2) Provide a Medusa app at `./app`

- If you already have one, copy it under `medusajs/app/`.
- Or scaffold a new one:

```bash
# from medusajs/
npx create-medusa-app@latest app
```

The command:

```
npx create-medusa-app@latest app
```

is a convenient way to **create a new Medusa eCommerce project** using the latest version of the `create-medusa-app` CLI tool. Here’s what it does in detail:

- **npx** runs a package called `create-medusa-app` without needing to install it globally.
- The `@latest` ensures you get the newest version.
- `app` is the folder name where the project will be created. It also becomes the name of the PostgreSQL database used.

When you run this command, it:

1. Downloads the Medusa starter project from the official GitHub repository (by default `medusa-starter-default`).
2. Creates a new project folder (`app`) with the necessary backend code and configuration.
3. Sets up a PostgreSQL database with the same name (`app`).
4. Runs database migrations to create tables and optionally seeds demo data.
5. Optionally installs a storefront starter (like Next.js) and/or an admin dashboard.
6. Opens the Medusa admin dashboard in your browser to configure user accounts and start managing the store.
7. Starts Medusa’s backend server locally at `http://localhost:9000`.

This command simplifies starting a full Medusa-based headless commerce app with minimal manual setup. It bundles backend, database, admin UI, and optionally a storefront starter all in one go.

In summary, it’s the easiest way to bootstrap a new Medusa project locally or in development, providing you a ready-to-use eCommerce backend and administration panel for customization and extension.

3) Start stack

```bash
# from medusajs/
docker compose up -d --build
```

4) Create admin user (optional)

```bash
docker compose exec medusa medusa user -e admin@example.com -p supersecret
```

5) Test API

```bash
curl -s http://localhost:9000/store/products | head
curl -s http://192.168.1.11:9000/store/products | head
```

6) Access Admin (served by backend)

- http://localhost:9000/app
- http://192.168.1.11:9000/app

## Services & Ports

- `postgres` → 5432
- `redis` → 6379
- `medusa` → 9000

If ports conflict, change the `ports:` in `docker-compose.yml` and update `DATABASE_URL`/`REDIS_URL` in `.env` accordingly.

## Notes

- The container binds to `0.0.0.0` so it’s reachable on your LAN IP `192.168.1.11` when ports are published.
- Data: Postgres is persisted in the `pg_data` named volume.
- This setup runs the backend only. You can add Admin/Storefront later if desired.
- For reverse proxy (Traefik/Nginx), add labels and point to `medusa:9000`.
