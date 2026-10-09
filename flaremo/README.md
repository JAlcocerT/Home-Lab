---
source_code: https://github.com/realchendahuang/FlareMo
post: https://fossengineer.com/selfhosting-flaremo-cloudflare-knowledge-base/
tags: ["cloudflare", "workers", "d1", "r2", "vectorize", "workers-ai", "memos", "knowledge-base"]
---

FlareMo is not a Docker Compose workload in this Home-Lab repo.

Self-hosting means deploying it into your own Cloudflare account.

A homelab server can be the deploy workstation for `pnpm` and `wrangler`, but
it is not the production runtime. A production FlareMo instance expects
Cloudflare Workers and the Cloudflare bindings below. Running it fully on a VPS
or mini PC would require a substantial port away from D1, R2, Queues,
Vectorize, Workers AI, and Workers Static Assets.

Core deployment shape:

- Cloudflare Worker for the Hono API and dynamic routes
- Workers Static Assets for the React/Vite PWA
- D1 for canonical memos, users, settings, auth tables, metadata, and tasks
- R2 for attachments, export bundles, and plugin assets
- Queues for member-removal cleanup and data exports
- Vectorize for memo and memory embedding indexes
- Workers AI for embeddings and AI memory workflows
- Rate Limiting binding for credential-sensitive routes
- Cron for maintenance
- Better Auth secrets for sessions and bootstrap

Manual deployment outline:

```bash
git clone https://github.com/realchendahuang/FlareMo.git
cd FlareMo
pnpm install
cp wrangler.jsonc.example wrangler.jsonc
pnpm provision:remote
pnpm exec wrangler secret put BETTER_AUTH_SECRET --config ./wrangler.jsonc
pnpm exec wrangler secret put FLAREMO_BOOTSTRAP_SECRET --config ./wrangler.jsonc
pnpm deploy:dry-run
pnpm deploy
```

First setup:

```text
https://your-flaremo-origin/setup
```

Use the `FLAREMO_BOOTSTRAP_SECRET` value to create the owner account.

Required GitHub Actions secrets if you use the deployment workflow:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `BETTER_AUTH_SECRET`
- `FLAREMO_BOOTSTRAP_SECRET`

Cloudflare API token permissions:

- Account -> Workers Scripts -> Edit
- Account -> D1 -> Edit
- Account -> Workers R2 Storage -> Edit
- Account -> Queues -> Edit
- Account -> Vectorize -> Edit
- Account -> Account Settings -> Read

Add zone permissions only when you manage domains/routes from automation:

- Zone -> Workers Routes -> Edit
- Zone -> DNS -> Edit

Optional credentials and vars:

- `FLAREMO_RECOVERY_SECRET`: break-glass owner recovery
- `FLAREMO_CF_ANALYTICS_TOKEN`: Cloudflare usage panel
- `FLAREMO_VAPID_PUBLIC_KEY` / `FLAREMO_VAPID_PRIVATE_KEY`: Web Push
- ASR provider keys: DashScope, Tencent, or MiniMax voice capture
- `FLAREMO_VOICE_CONFIG_KEY`: encrypt saved voice provider config

Application auth:

- humans use Better Auth cookie sessions;
- scripts, CLI, Memos-compatible clients, and MCP use `memos_pat_` PATs;
- Cloudflare Access is optional outer protection, not the application identity.

Local field note from the Foss Engineer analysis pass:

```bash
npx -y -p node@22 -p pnpm@11.7.0 pnpm install --frozen-lockfile --ignore-scripts
npx -y -p node@22 -p pnpm@11.7.0 pnpm --filter @flaremo/web build
npx -y -p node@22 -p pnpm@11.7.0 pnpm --filter @flaremo/worker check
```

Those checks passed. A full local UI run was not attempted because it requires a
configured `wrangler.jsonc`, `.dev.vars`, local D1 migrations, and Worker
bindings.
