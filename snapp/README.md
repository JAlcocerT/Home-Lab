# Snapp

Self-hosted URL shortener using the current Postgres-based Snapp image.

## Start

```bash
cp .env.sample .env
openssl rand -base64 32
docker compose up -d
```

Set `BETTER_AUTH_SECRET` to the generated secret and replace `POSTGRES_PASSWORD` before starting.

The default local URL is:

```text
http://localhost:3800
```

If you change `SNAPP_PORT` or deploy behind a domain, update `config/settings.yaml` so `hosts[0].origin` exactly matches the public URL you open in the browser. Snapp rejects requests for origins that are not configured there.
