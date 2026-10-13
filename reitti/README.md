# Reitti

[Reitti](https://github.com/dedicatedcode/reitti) is a self-hosted personal location tracking and analysis application. It turns GPS points from mobile apps and imports into a timeline with visits, trips, significant places, live sharing, maps, statistics, and optional Immich/photo context.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
docker compose up -d
```

Put the generated password in `POSTGIS_PASSWORD` before starting.

Open:

```text
http://192.168.1.2:3814
```

On first login, Reitti prompts you to set a new admin password.

## Services

- `reitti`: Spring Boot app and web UI.
- `postgis`: PostgreSQL/PostGIS database.
- `redis`: cache/coordination service.
- `tile-cache`: optional local tile cache used by the default compose.

The old local compose in this folder used RabbitMQ and Photon. The current upstream standard compose for Reitti 5 uses Redis and tile-cache instead; Photon or another geocoder can still be configured separately if you want local reverse geocoding.

## Validate

```bash
docker compose config
docker compose ps
curl -I http://127.0.0.1:3814
```

## Backup

Back up these Docker volumes:

```text
reitti_postgis-data
reitti_reitti-data
```

Redis and tile cache can usually be recreated.
