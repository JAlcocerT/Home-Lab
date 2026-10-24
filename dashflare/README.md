# Dashflare

Dashflare is a Cloudflare Worker analytics collector with Grafana for dashboards and Loki for log persistence.

## Local dashboard trial

```bash
cp .env.sample .env
docker compose pull
docker compose up -d
```

Open Grafana at:

```text
http://192.168.1.2:3822
```

The default Home-Lab credentials are `admin` and the password set in `.env`. Change it on first login.

This runs the Grafana/Loki side locally. The Worker is deployed separately with Wrangler and must send to a publicly reachable HTTPS Loki hostname. It cannot send to `loki:3100`, `localhost`, a private IP, or a custom port in `LOKI_HOST`.

The Loki data and Grafana state are stored in named volumes. Do not run `docker compose down -v` unless you intend to delete the local analytics data and dashboard state.
