---
source_code: https://github.com/GladysAssistant/Gladys
tags: ["smart home", "home automation", "iot", "docker", "self-hosting"]
---

# Gladys Assistant

Privacy-first smart-home hub.

```bash
cp .env.sample .env
openssl rand -hex 64
```

Put the generated value in `JWT_SECRET`, then start:

```bash
docker network inspect gladys-integrations >/dev/null 2>&1 || \
  docker network create \
    --driver bridge \
    --subnet 10.89.23.0/24 \
    --gateway 10.89.23.1 \
    --opt com.docker.network.bridge.enable_icc=false \
    gladys-integrations

docker compose up -d
```

Local URL:

```text
http://192.168.1.2:3823/
```

Health check:

```bash
curl http://127.0.0.1:3823/api/v1/ping
```

Gladys creates the first account through the onboarding flow. There is no
default username or password.

This compose intentionally follows Gladys' smart-home runtime model:

- `network_mode: host` for LAN discovery and mDNS;
- `privileged: true`, `/dev`, udev, and DBus for hardware integrations;
- `/var/run/docker.sock` so Gladys can manage Docker-based external integrations;
- `./data` for SQLite, DuckDB, backups, and persistent app state.

The explicit `gladys-integrations` network is only needed on Docker hosts that
have exhausted the default bridge address pools. It also makes the external
integration network deterministic on busy homelab machines.

Because this container can see Docker and host devices, keep it on a trusted
LAN/VPN or put it behind a proper authentication boundary before exposing it.
