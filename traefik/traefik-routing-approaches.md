**Traefik: Two Ways to Expose Services**

This doc shows two supported patterns to expose apps (e.g., Portainer, Termix) via Traefik:

- Docker provider (labels on the container, as internal service)
- File provider (config.yaml, as external service)

**Both work.**

Choose one per service to avoid duplicate routers.

---

## 1) Docker provider (recommended)

Traefik watches Docker and auto-configures routers/services from labels.

### Requirements

- The app container is attached to Traefik's network (e.g., `traefik_traefik-proxy`).
- Add Traefik labels to the service.
- No host `ports:` mapping needed (Traefik terminates HTTPS).

### Example (Portainer)

```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer_app
    restart: unless-stopped
    networks:
      - traefik_traefik-proxy
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik_traefik-proxy"

      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.routers.portainer.rule=Host(`portainer.x300.jalcocertech.com`)"

      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.portainer.middlewares=redirect-to-https"

      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`portainer.x300.jalcocertech.com`)"
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.tls.certresolver=cloudflare"

      - "traefik.http.routers.portainer-secure.service=portainer"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
networks:
  traefik_traefik-proxy:
    external: true
```

### Pros
- Minimal config; scales well.
- No need to reload Traefik for changes.

### Cons
- Labels can get verbose across many services.

---

## 2) File provider (config.yaml)

Routers and services are defined in `./config/config.yaml` (mounted into Traefik).

### Requirements

- Traefik must be able to reach the backend by DNS name or IP.
- Easiest: put the app on the same Docker network as Traefik so you can use the container name.

```sh
docker network connect traefik_traefik-proxy portainer
```

### Example (Portainer over HTTP 9000)

`traefik/config/config.yaml`:
```yaml
http:
  middlewares:
    https-redirectscheme:
      redirectScheme:
        scheme: https
        permanent: true

  routers:
    portainer:
      entryPoints: ["https"]
      rule: "Host(`portainer.x300.jalcocertech.com`)"
      middlewares:
        - https-redirectscheme
      tls: {}
      service: portainer

  services:
    portainer:
      loadBalancer:
        servers:
          - url: "http://portainer_app:9000"
        passHostHeader: true
```
In the Portainer compose, ensure it joins the Traefik network:

```yaml
networks:
  - traefik_traefik-proxy
```

### If your backend uses HTTPS

- Use `https://portainer_app:9443` and, if self-signed, add a `serversTransport` with `insecureSkipVerify: true`, then reference it from the service.

### Pros
- Centralized routing/security logic in one file.
- Useful for non-Docker/backends outside the Docker provider.

### Cons
- Manual edits and reloads.
- Need to ensure name/IP is reachable from the Traefik container.

---

## Choosing an approach

- Prefer Docker provider for containers managed by Docker Compose/Swarm.
- Use File provider for:
  - External services (VMs, bare metal) reachable by IP/DNS.
  - Advanced shared middlewares or when you want zero labels in app compose files.

---

## Troubleshooting

- Router not appearing: check `traefik.enable=true` (Docker) or `config.yaml` syntax (File provider).
- 404 from Traefik: ensure `rule` host matches the URL and TLS entrypoint is correct.
- Backend unreachable: confirm shared network and that the name (e.g., `portainer_app`) resolves inside the Traefik container.
- ACME errors: `acme.json` must exist with `chmod 600` and your DNS provider credentials must be valid.