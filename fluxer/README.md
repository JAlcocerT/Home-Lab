# Fluxer Self-Hosting

This folder mirrors Fluxer's official `deploy/self-hosting` Docker Compose
layout with a safer `.env.sample` for public Home-Lab use.

Fluxer is not a single static web app. The browser client is served by the app
proxy, but full functionality also needs API, worker, gateway, media proxy,
LiveKit voice, Postgres, Valkey, NATS, Meilisearch, and SeaweedFS services.

## Start

```bash
cp .env.sample .env
$EDITOR .env
docker compose up -d
```

Generate real secrets before starting the stack:

```bash
openssl rand -hex 32
openssl rand -base64 32
```

Generate VAPID keys with a Web Push/VAPID tool and place the public/private
pair in `.env`.

## Reverse Proxy

For Traefik, nginx, Caddy, or HAProxy in front of Fluxer:

```env
COMPOSE_FILE=docker-compose.yml:docker-compose.proxy.yml
FLUXER_EDGE_BIND=127.0.0.1:8080
FLUXER_PUBLIC_SCHEME=https
FLUXER_PUBLIC_PORT=443
```

Forward the whole host to `http://127.0.0.1:8080`.

## Tunnel

For Cloudflare Tunnel or a similar TLS-terminating tunnel:

```env
COMPOSE_FILE=docker-compose.yml:tunnel.compose.yml
FLUXER_HTTP_PORT=127.0.0.1:8080
FLUXER_PUBLIC_SCHEME=https
FLUXER_PUBLIC_PORT=443
```

The tunnel points at `http://127.0.0.1:8080`.

## Validation

```bash
docker compose --env-file .env.sample config >/tmp/fluxer-compose.yml
```
