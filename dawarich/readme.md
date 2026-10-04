---
source_code: https://github.com/Freika/dawarich
post: https://fossengineer.com/selfhosting-dawarich/
tags: ["travel", "location", "maps", "docker"]
---

## Dawarich

Dawarich is a self-hosted location history tracker and Google Timeline alternative.

```sh
cp .env.sample .env
openssl rand -hex 64
docker compose config
docker compose up -d
```

Update `.env` before starting the stack. At minimum, replace `POSTGRES_PASSWORD` and `SECRET_KEY_BASE`.
