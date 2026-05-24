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

> `http://127.0.0.1:8448/_matrix/client/versions`

> > `http://127.0.0.1:8448/`

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

Local learnings from this host
- The editor/agent shell is inside a Flatpak runtime, so plain `docker` may not be visible there. Use host Docker through `host-spawn` when needed:
  - `host-spawn docker compose up -d`
  - `host-spawn docker ps`
  - `host-spawn curl -fsS http://127.0.0.1:8448/_matrix/client/versions`
- The active compose file stores Conduit data in `./data` and mounts it to `/var/lib/matrix-conduit` in the container. This avoids needing sudo for `/home/docker/conduit` and keeps this stack isolated.
- `./data` is ignored by git because it contains the live RocksDB database.
- Check port usage before starting. On this host, existing containers were using `3000`, `5555`, and `8000`; port `8448` was free for Conduit.
- The Matrix versions endpoint responded successfully at `http://127.0.0.1:8448/_matrix/client/versions`.
- The upstream image does not include `wget` or `sh`, so a compose healthcheck that runs `wget` inside the container fails even when Conduit is working. Verify from the host instead, or build a custom image if an internal healthcheck is required.
- Keep `allow_registration = false` for normal operation. Temporarily set it to `true` only to create the first admin account, then set it back to `false` and restart.
- This setup is enough for local/LAN testing. For public federation, add a real domain, TLS reverse proxy, firewall rules, and Matrix `.well-known` responses.

FAQ

What is RocksDB?
- RocksDB is the embedded database engine used by this Conduit setup.
- Embedded means there is no separate database container. Conduit writes directly to database files under `./data`, mounted in the container as `/var/lib/matrix-conduit`.
- It stores local homeserver state such as users, rooms, events/messages, federation data, media metadata, keys, and internal Conduit state.
- For a small home server, this is simple and efficient because only the Conduit container needs to run.
- Treat `./data` as critical persistent data. Back it up, do not edit it manually, and do not delete it unless you want to erase this homeserver.

How is this different from Matrix Synapse?
- Conduit commonly uses RocksDB as an embedded database.
- Matrix Synapse commonly uses PostgreSQL for production deployments.
- With Synapse and PostgreSQL, you usually run at least two services: the Synapse homeserver and a PostgreSQL database container or external PostgreSQL server.
- PostgreSQL gives stronger operational tooling for larger deployments, backups, migrations, replication, monitoring, and database inspection.
- RocksDB keeps the home-lab setup simpler because there is no separate database service to maintain.
- Practical tradeoff: Conduit with RocksDB is easier to run for a small/self-hosted setup; Synapse with PostgreSQL is the more established and heavier production pattern.

Can I connect with Element for local testing?
- Yes. Use Element Desktop or another Matrix client that allows plain HTTP homeservers.
- From this PC, use `http://127.0.0.1:8448` as the homeserver URL.
- From another device on the LAN, use `http://192.168.1.11:8448`.
- Browser-based `app.element.io` may reject or block this local homeserver because the hosted Element app uses HTTPS while this test server is plain HTTP.
- Registration is disabled by default. To create the first account, temporarily set `allow_registration = true` in `conduit.toml`, restart Conduit, register with Element, then set `allow_registration = false` again and restart.
- Restart command from this Flatpak-based shell:
  - `host-spawn docker compose restart conduit`
- After registration, the Matrix user ID will look similar to `@youruser:192.168.1.11`.

How do I install Element Desktop on Ubuntu from the CLI?
- Official Element Desktop Debian/Ubuntu packages are available from Element's apt repository.
- Install it with:

```sh
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
sudo apt update
sudo apt install element-desktop
```

- Then open Element Desktop and use `http://127.0.0.1:8448` as the homeserver URL on this PC, or `http://192.168.1.11:8448` from another LAN device.
