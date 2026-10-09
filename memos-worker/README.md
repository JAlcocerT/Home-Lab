# Memos Worker Home-Lab Notes

Memos Worker is not a Docker Compose homelab app. It is a Cloudflare-native notes application that runs on Workers with D1, KV, and R2 bindings.

Repository: https://github.com/souvenp/memos-worker  
Foss Engineer post: `/selfhosting-memos-worker-cloudflare-notes/`

## Why There Is No Compose File

The production runtime is Cloudflare:

| Binding | Service | Purpose |
| --- | --- | --- |
| `DB` | D1 | Notes, tags, docs nodes, FTS search |
| `NOTES_KV` | Workers KV | Sessions, settings, public share mappings |
| `NOTES_R2_BUCKET` | R2 | Attachments and uploaded images |

Wrangler can simulate this locally for development, but a normal compose file would not reproduce the production platform.

## Required Worker Variables

Use encrypted Worker variables/secrets for:

```text
USERNAME=<your-login-user>
PASSWORD=<strong-password>
```

Optional Telegram capture:

```text
TELEGRAM_BOT_TOKEN=<telegram-bot-token>
TELEGRAM_WEBHOOK_SECRET=<long-random-secret>
AUTHORIZED_TELEGRAM_IDS=<single-telegram-user-id>
```

In the analyzed source, `AUTHORIZED_TELEGRAM_IDS` behaves like one sender ID, not a comma-separated list.

## Local Dev Notes

The project needs Node 20+ for Wrangler 4. This worked in the local trial:

```bash
cd /tmp/foss-memos-worker-20261006
npm ci
npx -y -p node@24 -p npm@latest bash -lc 'npx wrangler d1 execute notes-db --local --file=./src/schema.sql'
npx -y -p node@24 -p npm@latest bash -lc 'npx wrangler dev --ip 127.0.0.1 --port 8791'
```

For local development, create `.dev.vars` with non-public local values:

```text
USERNAME="dev_user"
PASSWORD="dev_password"
TELEGRAM_BOT_TOKEN=""
TELEGRAM_WEBHOOK_SECRET=""
AUTHORIZED_TELEGRAM_IDS=""
```

Wrangler validates placeholder binding values in `wrangler.toml`, so use syntactically valid dummy IDs when testing locally.

## Smoke Test Commands

```bash
curl http://127.0.0.1:8791/

curl -c /tmp/memos-worker-cookies.txt \
  -H 'Content-Type: application/json' \
  -d '{"username":"dev_user","password":"dev_password"}' \
  http://127.0.0.1:8791/api/login

curl -b /tmp/memos-worker-cookies.txt \
  -F 'content=# hello from local smoke test

#cloudflare #memos-worker' \
  http://127.0.0.1:8791/api/notes

curl -b /tmp/memos-worker-cookies.txt \
  'http://127.0.0.1:8791/api/search?q=cloudflare'
```

Observed in the local trial:

- UI served successfully;
- login succeeded;
- note creation returned `201 Created`;
- FTS search returned the created note;
- tags and stats endpoints worked;
- public share/raw Markdown URLs were generated.

## Production Deployment Checklist

1. Create a D1 database.
2. Execute `src/schema.sql` against it.
3. Create a KV namespace.
4. Create an R2 bucket.
5. Fill `wrangler.toml` with the real D1/KV/R2 IDs and names.
6. Add Worker secrets for `USERNAME` and `PASSWORD`.
7. Add Telegram variables only if using Telegram capture.
8. Deploy with Cloudflare Git integration or `npx wrangler deploy`.
