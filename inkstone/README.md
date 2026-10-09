# Inkstone Home-Lab Notes

Inkstone is not a normal Home-Lab Docker Compose service. It is a Cloudflare-native Markdown notebook that expects Workers, D1, R2 or KV, Workers KV, Durable Objects, cron triggers, and optional Workers AI.

Repository: https://github.com/shuaiplus/inkstone  
Foss Engineer post: `/selfhosting-inkstone-cloudflare-markdown-notebook/`

## What This Folder Is For

This folder documents how I tested and would deploy Inkstone. There is no `docker-compose.yml` here because a compose file would not reproduce the full Cloudflare runtime.

## Cloudflare Resources

| Binding | Resource | Purpose |
| --- | --- | --- |
| `DB` | D1 | Users, notes, folders, tags, versions, shares, search indexes, settings |
| `FILES` | R2 | Attachments and avatars in default mode |
| `FILES_KV` | Workers KV | Alternative attachment storage in KV mode |
| `OAUTH_KV` | Workers KV | MCP OAuth registrations, codes, tokens, grants |
| `SYNC_HUB` | Durable Object | Realtime sync notifications and polling fallback |
| `CREDENTIAL_VAULT` | Durable Object | Encryption service for backup credentials and TOTP secrets |
| `AI` | Workers AI | Optional semantic search embeddings |
| `ASSETS` | Workers Static Assets | React frontend |

## Local Trial

The checked-in lockfile points at `registry.npmmirror.com`, and `npm ci` failed in this environment with `EALLOWREMOTE`.

The following commands worked for source validation:

```bash
cd /tmp/foss-inkstone-20261006-b
npx -y -p node@24 -p npm@latest bash -lc 'npm install --package-lock=false --ignore-scripts'
npx -y -p node@24 -p npm@latest bash -lc 'npm run build'
npx -y -p node@24 -p npm@latest bash -lc 'npm run typecheck'
```

Observed result:

- Node `v24.21.0`;
- npm `12.2.0`;
- build passed;
- typecheck passed;
- npm reported 7 vulnerabilities during install;
- Vite warned about large chunks.

## Commands

Default R2 mode:

```bash
npm install
npm run build
npm run deploy
```

KV attachment mode:

```bash
npm run build:kv
npm run deploy:kv
```

Local development:

```bash
npm run dev
npm run dev:kv
npm run dev:demo
```

Default local dev port: `7712`  
Preview port: `7713`

## Deployment Notes

For CLI or CI deployment, expect:

- `CLOUDFLARE_ACCOUNT_ID`;
- `CLOUDFLARE_API_TOKEN`;
- Workers deployment permissions;
- D1 edit permissions;
- R2 edit permissions for default mode;
- KV edit permissions for `OAUTH_KV` and optional `FILES_KV`;
- Durable Object deployment/migration permissions;
- Workers AI enabled only if semantic search is desired;
- DNS/route permissions only when attaching a custom domain.

## Backup Notes

Inkstone supports JSON/ZIP export and WebDAV/S3 backups. The app remains database-backed in production, but exports and backups keep Markdown readable enough for migration planning.
