---
source_code: https://github.com/cloudflarebase/cloudflarebase
post: https://fossengineer.com/selfhosting-cloudflarebase-firebase-cloudflare/
tags: ["cloudflare", "workers", "durable-objects", "d1", "r2", "firebase-alternative"]
---

CloudflareBase is not a Docker Compose service.

Self-hosting means deploying the CloudflareBase dashboard and agents into your
own Cloudflare account.

Core deployment shape:

- dashboard Worker: SvelteKit console and project registry;
- auth agent Worker: Better Auth on per-project Durable Objects;
- database agent Worker: documents, typed tables, live queries, and remote
  config on Durable Objects;
- storage agent Worker: R2-backed object storage with Durable Object indexes;
- hosting agent Worker: optional Workers for Platforms hosting;
- D1: control-plane project registry;
- service bindings: private dashboard-to-agent calls.

Upstream quickstart:

```bash
git clone https://github.com/cloudflarebase/cloudflarebase.git
cd cloudflarebase
npm install
npm run dev
```

Deploy to your Cloudflare account:

```bash
npx wrangler login
npm run deploy:all
npx wrangler secret put CONSOLE_SETUP_TOKEN
```

`CONSOLE_SETUP_TOKEN` should be at least 24 characters. It protects the first
console claim so a fresh public deployment cannot be owned by whoever visits
`/login` first.

There is intentionally no `docker-compose.yml` here because the application is
not a self-contained VPS stack. Optional features require matching Cloudflare
services:

- R2 for storage;
- Workers for Platforms for app hosting;
- Analytics Engine for charts;
- Workers AI for copilot/chat surfaces;
- Cloudflare Email/Send Email binding for auth email;
- Google/GitHub OAuth credentials for social login.

Local field note: this repo pins Node `22.18.0`. On a host with Node 18.19.1,
`npm install` fails with `EBADENGINE`, so use Node 22.18.0 or a supported Node
24 release before trying local dev.
