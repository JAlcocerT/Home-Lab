---
source_code: https://github.com/open-wanderer/wanderer
post: https://fossengineer.com/selfhosting-wanderer-trail-database/
tags: ["maps", "trails", "gpx", "pocketbase", "meilisearch"]
---

# Wanderer

Wanderer is a self-hosted trail database and route planning app. This compose exposes only the web UI on `3815`; PocketBase and Meilisearch stay on the internal Docker network.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
openssl rand -hex 16
openssl rand -hex 32
docker compose up -d
```

Open:

```text
http://192.168.1.2:3815
```

Use the first signup screen to create your admin/user account. After that, set `PUBLIC_DISABLE_SIGNUP=true` if the instance should be private.

## Notes

- `ORIGIN` must match the URL users open in the browser.
- `MEILI_MASTER_KEY`, `POCKETBASE_ENCRYPTION_KEY`, and `POCKETBASE_PROXY_SECRET` should never be committed.
- The default compose uses hosted Overpass, Valhalla, and Nominatim endpoints. Self-hosting those services is possible, but Valhalla map data can be large.
