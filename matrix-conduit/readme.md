---
source_code: https://gitlab.com/famedly/conduit
tags: ["matrix", "chat"]
post: 
---

Thanks to [ugeek](https://ugeek.github.io/blog/post/2022-07-11-conduit-el-matrix-escrito-en-rust.html)

```sh
docker compose up -d
#docker compose logs --tail=200 conduit
sudo docker compose down
```

Matrix Conduit (Rust) homeserver via Docker Compose.

- Upstream docs: https://docs.conduit.rs/deploying/docker.html
- Docker Hub: https://hub.docker.com/r/matrixconduit/matrix-conduit

Default ports
- 8448 (host) -> 6167 (container) for federation/client. In production, put Conduit behind Traefik/Nginx with TLS.

Data path
- `/home/docker/conduit` -> `/var/lib/matrix-conduit` (container)

Minimal setup
1) Edit `conduit/docker-compose.yml` and set:
   - `CONDUIT_SERVER_NAME` to your domain (e.g. `matrix.example.com`). For LAN tests you can use `192.168.1.11`.
   - `CONDUIT_ALLOW_REGISTRATION=true` temporarily to create the first user (admin), then set it back to `false`.
2) Create the data dir:
   - `mkdir -p /home/docker/conduit`
3) Start:
   - `docker compose up -d`
4) Create the first user (admin):
   - Using a client (Element): register immediately after bringing up the server.

Well-known and reverse proxy
- For federation without exposing 8448 directly, serve these JSON files at your root domain via your reverse proxy:
  - `/.well-known/matrix/server` -> `{ "m.server": "matrix.example.com:443" }`
  - `/.well-known/matrix/client` -> `{ "m.homeserver": { "base_url": "https://matrix.example.com" } }`
- Conduit docs include compose variants for Traefik/Nginx if you prefer that route.

TURN for calls (optional)
- Conduit recommends Coturn. Basic env variants:
  - `CONDUIT_TURN_URIS='["turn:turn.example.com?transport=udp", "turn:turn.example.com?transport=tcp"]'`
  - `CONDUIT_TURN_SECRET=<your-coturn-secret>`
- See: https://docs.conduit.rs/deploying/docker.html

Notes
- You can configure entirely via `CONDUIT_*` env vars by setting `CONDUIT_CONFIG=""` and adding more variables.
- `rocksdb` is the default embedded DB. For small/home setups this is fine.
- For production, add Traefik labels or Nginx config, enable TLS, and harden your firewall.
