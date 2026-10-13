---
source_code: https://github.com/karl-cta/statup
post: https://fossengineer.com/selfhosting-statup-status-page/
tags: ["Status Page", "Monitoring", "SQLite", "Rust"]
---

# Statup

Statup is a lightweight self-hosted status page for outages, maintenance windows, service notices, and basic web/TCP checks.

## Start

```bash
cd /home/jalcocert/Desktop/Home-Lab/statup
cp .env.sample .env
docker compose up -d
```

Open:

```text
http://192.168.1.2:3811
```

If `ADMIN_EMAIL` and `ADMIN_PASSWORD` are not set, the first browser registration creates the administrator account.

## Health

```bash
docker compose ps
curl http://127.0.0.1:3811/health
```

## Notes

This compose pins `ghcr.io/karl-cta/statup:0.4.0` instead of `latest`. Statup is pre-v1, so back up the `statup-data` volume before upgrading.

`UPDATE_CHECK=false` avoids the daily GitHub version check in this Home-Lab setup. Set it to `true` if you want the UI to notify administrators about new releases.
