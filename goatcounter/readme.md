---
source_code: https://github.com/arp242/goatcounter
tags: "web-analytics"
---

```sh
docker compose up -d db
docker compose run --rm goatcounter \
  db create site -createdb \
  -vhost stats.yourdomain.com \
  -user.email admin@example.com
docker compose up -d
```

> Lightweight tracker (<1KB) without cookies, IP addresses, or additional identifiers, ensuring compliance with GDPR, PECR, and other regulations.