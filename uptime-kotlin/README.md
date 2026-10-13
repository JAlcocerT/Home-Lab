---
source_code: https://github.com/TheoMeunier/uptime-kotlin
post: https://fossengineer.com/selfhosting-uptime-kotlin-monitoring/
tags: ["Monitoring", "Status Page", "Kotlin", "Quarkus", "PostgreSQL"]
---

# Uptime Kotlin

Uptime Kotlin is a self-hosted uptime monitor built with Kotlin, Quarkus, React, and PostgreSQL.

## Start

```bash
cd /home/jalcocert/Desktop/Home-Lab/uptime-kotlin
cp .env.sample .env
openssl rand -base64 32
nano .env
docker compose up -d
```

Open:

```text
http://192.168.1.2:3812
```

The first user is created from the web onboarding flow.

## Health

```bash
curl http://127.0.0.1:3812/q/health
docker compose ps
```

## Notes

Keep `ENCRYPTION_MASTER_KEY` permanently. It encrypts stored monitor/notification secrets and the JWT signing key. If it is lost, encrypted secrets must be re-entered.

This compose runs the all-in-one container where the web app, API, and scheduler run together. For larger deployments, Uptime Kotlin also supports a worker image and database-backed cluster mode.
