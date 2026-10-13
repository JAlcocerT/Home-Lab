---
source_code: https://github.com/kOlapsis/maintenant
post: https://fossengineer.com/selfhosting-maintenant-docker-kubernetes-monitoring/
tags: ["Monitoring", "Docker", "Kubernetes", "Status Pages"]
---

# Maintenant

Maintenant is a single-container monitoring dashboard for Docker, Swarm, Kubernetes, endpoint checks, TLS certificates, heartbeats, status pages, alerts, logs, and update/security visibility.

## Start

```bash
cd /home/jalcocert/Desktop/Home-Lab/maintenant
cp .env.sample .env
docker compose up -d
```

Open:

```text
http://192.168.1.2:3810
```

## Health

```bash
docker compose ps
docker compose logs -f maintenant
curl -I http://127.0.0.1:3810/
```

## Security Notes

Maintenant has no built-in user login. The direct LAN port in this compose is for local testing. Before exposing it outside a trusted LAN, put it behind a reverse proxy with authentication such as Authelia, Authentik, OAuth2 Proxy, or Cloudflare Access.

The Docker socket mount is read-only but still sensitive. It lets Maintenant inspect containers, logs, labels, and runtime state. For a harder production setup, use a Docker socket proxy and restrict which Docker API routes the app can reach.

Telemetry is disabled by default in this Home-Lab compose with `MAINTENANT_DISABLE_TELEMETRY=true`.
