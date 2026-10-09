---
source_code: https://github.com/lissy93/domain-locker
post: https://fossengineer.com/selfhosting-domain-locker/
tags: ["domains", "monitoring", "docker"]
---

# Domain Locker

Domain Locker keeps a private inventory of domain names, expiry dates, registrar/host data, DNS, SSL, uptime history, costs, tags, notes, and notification rules.

Start with:

```bash
cp .env.sample .env
# edit DL_AUTH_PASSWORD and DL_AUTH_SECRET first
docker compose up -d
```

Open:

```text
http://localhost:6161
```

This Compose uses the current simple self-hosting path: one app container with SQLite stored in the `domain_locker_data` volume.

Do not expose Domain Locker publicly without authentication and a reverse proxy. It stores sensitive domain portfolio data and can run scheduled lookups/monitoring jobs.
