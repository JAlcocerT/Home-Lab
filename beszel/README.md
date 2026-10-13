# Beszel

[Beszel](https://github.com/henrygd/beszel) is a lightweight self-hosted server monitoring hub with historical host metrics, Docker/Podman container stats, alerts, network monitors, SMART/ZFS data, and a small Go agent.

This folder keeps the hub and agent separate on purpose:

- `docker-compose.yml` starts the Beszel hub only.
- `agent.compose.yml` starts a local Beszel agent after you copy the generated key/token from the hub UI.

## Start the Hub

```bash
cp .env.sample .env
docker compose up -d
```

Open:

```text
http://192.168.1.2:3813
```

There is no `admin/admin` default login. On a fresh data directory, create the first user in the web UI.

## Add the Local Agent

After the hub is running and you have created the first account:

1. Open Beszel.
2. Go to `Systems`.
3. Click `Add system`.
4. Copy the generated Docker/Linux values for `HUB_URL`, `TOKEN`, and `KEY`.
5. Put them in `.env`.
6. Start the agent:

```bash
docker compose -f docker-compose.yml -f agent.compose.yml up -d
```

The agent uses `network_mode: host` and a read-only Docker socket mount so Beszel can see host networking and container statistics.

## Validate

```bash
docker compose ps
curl -I http://127.0.0.1:3813
docker compose logs -f beszel
```

If you enable the agent:

```bash
docker compose -f docker-compose.yml -f agent.compose.yml logs -f beszel-agent
```

## Backup

Back up these folders:

```text
beszel_data/
beszel_agent_data/
```

The hub data lives in `beszel_data`. The agent data lives in `beszel_agent_data` if you start the optional agent compose file.
