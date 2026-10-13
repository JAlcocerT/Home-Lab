---
source_code: https://github.com/danileau/prettypleaseprint
tags: ["3D printer", "print queue", "Next.js", "Postgres"]
---

# Pretty Please Print

Invite-only 3D print request queue for a small office or homelab.

```bash
cp .env.sample .env
openssl rand -base64 32
openssl rand -hex 24
```

Put those generated values into `BETTER_AUTH_SECRET` and `DB_PASSWORD`, then:

```bash
docker compose up -d
docker compose logs migrate
```

The migrator prints a one-use admin set-password link. Open it within 30
minutes, then invite other users from the admin UI.

Local demo URL:

```text
https://192.168.1.2:3819/
```

This compose uses Caddy with an internal/self-signed TLS certificate because
Pretty Please Print refuses production auth over plain HTTP except on localhost.
Your browser will likely show a certificate warning until you trust the Caddy
local CA.

For a real deployment, use a valid HTTPS domain, set `APP_URL` to that origin,
set `PASSKEY_RP_ID` to the domain without scheme or port, and put the app
behind your normal reverse proxy or Cloudflare Tunnel.
