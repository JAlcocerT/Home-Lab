# Monolith

Monolith is not a Docker Compose workload in this Home-Lab repo.

It is a Cloudflare-native blog/CMS built around:

- Cloudflare Pages for the React/Vite frontend
- Cloudflare Pages Functions as the same-origin proxy
- Cloudflare Workers for the Hono backend API
- Cloudflare D1 for the default database
- Cloudflare R2 for media and backups
- optional Analytics Engine, Turnstile, Resend, Turso, PostgreSQL, S3-compatible storage, and WebDAV

Repository:

```text
https://github.com/one-ea/Monolith
```

## Why there is no docker-compose.yml

The upstream project does not ship a Dockerfile or `docker-compose.yml`.

Self-hosting Monolith means deploying it into your own Cloudflare account, not running a portable container stack on a local VPS.

## Practical deployment checklist

Use Node 22 for CI parity. The repository currently has `.nvmrc` set to `20`, but `package.json` requires `node >=22` and the GitHub Actions deployment uses Node 22.

```bash
git clone https://github.com/one-ea/Monolith.git
cd Monolith
npm ci
export ADMIN_PASSWORD='replace-with-a-strong-admin-password'
export JWT_SECRET="$(openssl rand -base64 32)"
npx wrangler login
npm run deploy:cloudflare
```

The deploy script applies remote D1 migrations, reconciles schema columns, deploys the Worker, writes Pages `API_BASE`, builds the client, and deploys Pages.

## Minimum Cloudflare resources

- Worker: `monolith-server`
- Pages project: `monolith-client`
- D1 database: `monolith-db`
- R2 bucket: `monolith-assets`
- Pages secret: `API_BASE`
- Worker secrets: `ADMIN_PASSWORD`, `JWT_SECRET`

Optional:

- `TURNSTILE_SECRET`
- `RESEND_API_KEY`
- `REACTION_SALT`
- `CLOUDFLARE_API_TOKEN` for Analytics Engine queries
- `DB_PROVIDER=turso` with `TURSO_URL`
- `DB_PROVIDER=postgres` with `DATABASE_URL`
- `STORAGE_PROVIDER=s3` with S3-compatible credentials

## Local validation from the FOSS post pass

In a temporary clone, with Node 22 supplied through `npx`:

```bash
npx -y -p node@22 -p npm@11 npm ci
NODE22_DIR=$(dirname "$(npx -y -p node@22 which node)") && PATH="$NODE22_DIR:$PATH" npm run build
NODE22_DIR=$(dirname "$(npx -y -p node@22 which node)") && PATH="$NODE22_DIR:$PATH" npm run check
```

Results:

- dependencies installed
- frontend build passed
- PWA service worker generated
- client and server type checks passed
- `npm run doctor:local` still failed because `server/.dev.vars` was intentionally not created

For a full local dev run, create `server/.dev.vars` with local-only secrets and initialize Wrangler's local D1/R2 state.
