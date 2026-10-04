---
source_code: https://github.com/tess1o/geopulse
docs: https://tess1o.github.io/geopulse/
post: https://fossengineer.com/selfhosting-geopulse/
tags: ["travel", "location", "maps", "docker", "postgis"]
---

## GeoPulse

GeoPulse is a self-hosted location timeline platform for GPS imports, OwnTracks/Overland/GPSLogger ingestion, trip detection, analytics, sharing, and Immich photo context.

```sh
cp .env.sample .env
docker compose config
docker compose up -d
```

Update `.env` before starting the stack. At minimum, replace `GEOPULSE_POSTGRES_PASSWORD` and set `GEOPULSE_ADMIN_EMAIL` to the email that should become the first administrator.
