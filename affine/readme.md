---
post:
source_code: https://github.com/toeverything/affine
official_docs: https://affinehub.com/docs
---

The goal is to provide a complete, persistent setup for Affine.

Components

- **Affine**: Main application on port 3015.
- **Postgres**: Database for persistent data.
- **Redis**: Cache for better performance.

See  https://docs.affine.pro/self-host-affine/install/docker-compose-recommend

```sh
wget -O docker-compose.yml https://github.com/toeverything/affine/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/toeverything/affine/releases/latest/download/default.env.example
docker compose up -d
docker compose logs
```

Go to `http://localhost:3010`

Or connect the desktop application via appimage: https://affine.pro/download?channel=stable or https://github.com/toeverything/AFFiNE/releases