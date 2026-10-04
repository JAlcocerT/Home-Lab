# Rallly

Self-hosted Rallly v4 compose reference for a local or external reverse proxy setup.

For a guided production install, upstream recommends:

```bash
curl -fsSL https://get.rallly.co | bash
```

This folder keeps the compose files visible for review. Copy `.env.sample` to `.env`, replace every generated secret placeholder, and start local/external-proxy mode with:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.external-proxy.yml COMPOSE_PROFILES=bundled-db,bundled-storage docker compose up -d
```

Use `PROXY_MODE=bundled` plus the `bundled-proxy` profile if you want the included Traefik service to manage ports 80/443 and Let's Encrypt certificates.

## Local magic-link testing with Mailpit

For a local test where Rallly sends login links to Mailpit:

```dotenv
SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_SECURE=false
```

Then start the stack with the Mailpit override:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.external-proxy.yml:docker-compose.mailpit.yml COMPOSE_PROFILES=bundled-db,bundled-storage docker compose up -d
```

Open Rallly at `http://localhost:3000`, request a login link, and read it in Mailpit at `http://localhost:8025`.
