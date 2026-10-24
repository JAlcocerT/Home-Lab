# Omnivore

Standalone Home-Lab deployment of the self-hosted Omnivore image.

The upstream published standalone image currently has no matching `linux/amd64` manifest on this host, so this setup builds it locally. Clone the source before starting:

```bash
git clone --depth 1 https://github.com/omnivore-app/omnivore.git source
```

## Start

```bash
cp .env.sample .env
openssl rand -hex 32
```

Put generated values into `JWT_SECRET`, `SSO_JWT_SECRET`, and `VERIFICATION_TOKEN`, then start it:

```bash
docker compose pull
docker compose up -d
docker compose logs -f omnivore
```

Open `http://192.168.1.2:3010`.

The API is mapped to `http://192.168.1.2:4010`. The bundled database is persisted in the `omnivore-data` Docker volume.

The initial image creates the demo account documented upstream:

```text
demo@omnivore.work
demo_password
```

Change or remove it before exposing the service beyond the local network.

This quick deployment uses the standalone image plus Redis for background queues. MinIO, email ingestion, image proxy, Discover, and the separate content-fetch deployment are not enabled here.
