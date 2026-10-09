---
source_code: https://github.com/danielsyauqi/Seeder
post: https://fossengineer.com/selfhosting-seeder-project-manager/
tags: ["project-management", "kanban", "client-board", "mcp", "docker", "sqlite", "cloudflare"]
---

Seeder is an open-source project manager for small teams, client work, and
agent-assisted task workflows.

This Home-Lab folder uses the simple Docker/Node path:

- app image: `ghcr.io/danielsyauqi/seeder:latest`
- database: local SQLite file at `/app/data/seeder.db`
- uploads: local disk under `/app/data/uploads`
- public port: `3031` by default

Create your env file:

```bash
cp .env.sample .env
openssl rand -base64 32
openssl rand -base64 32
```

Use one generated value for `BETTER_AUTH_SECRET` and a different generated
value for `VCS_ENCRYPTION_KEY`.

Then start it:

```bash
docker compose up -d
```

Open:

```text
http://localhost:3031/sign-in
```

Bootstrap model:

- the first owner account must use `OWNER_EMAIL`;
- sign-up is only open while the instance has zero users;
- after the owner exists, onboarding is invite-only;
- there is no default password, you choose it on first sign-up;
- optional Google sign-in can be enabled, but implicit public signup is still
  disabled by Seeder's auth configuration.

Do not scale this compose service horizontally. The Docker path uses SQLite,
which is a single-writer database and should run as one app instance with one
persistent volume.

Cloudflare deployment is a different mode: Seeder can run on Workers with D1
for relational storage and R2 for uploads. This Docker folder intentionally
uses the local Node/SQLite path for a compact homelab deployment.
