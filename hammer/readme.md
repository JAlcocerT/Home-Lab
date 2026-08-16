---
post: https://fossengineer.com/hammer-editor-self-hosted-sync/
source_code: https://github.com/Darkrock-Studios/hammer-editor
official_docs: https://github.com/Darkrock-Studios/hammer-editor/blob/main/docs/HOW-TO-RUN-A-SERVER-DOCKER.md
tags: ["Writing", "Local-First", "Sync", "Self-Hosting"]
---

Hammer is a local-first story editor with an optional self-hosted sync server.

```sh
docker compose up -d
docker compose logs -f
```

The compose file exposes the server on `127.0.0.1:8080` by default. Hammer clients require HTTPS, so put a reverse proxy such as Caddy, Traefik, or Nginx in front of the container before connecting a desktop or mobile client.

The first account created on a new server becomes the admin account. Durable data lives in the named `hammer-data` volume under `/data/hammer_data/`.
