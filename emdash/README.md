---
source_code: https://github.com/emdash-cms/emdash
post: https://fossengineer.com/selfhosting-emdash-astro-cms/
tags: ["cms", "astro", "typescript", "sqlite", "cloudflare", "d1", "r2", "wordpress-alternative"]
---

EmDash is an Astro-native TypeScript CMS. This Home-Lab folder uses the
upstream Dockerfile and builds the Node/SQLite blog-template path from a pinned
source commit.

This is not a tiny prebuilt image. Expect a source build with pnpm workspace
dependencies and Astro package builds.

Start it:

```bash
cp .env.sample .env
docker compose up -d --build
```

Open:

```text
http://localhost:4321/
http://localhost:4321/_emdash/admin
```

Local stack:

- Astro Node standalone server
- SQLite content database
- local upload directory
- persistent Docker volumes for `/app/data` and `/app/uploads`

Cloudflare deployment is a different mode. The Cloudflare template uses
Workers, D1, R2, and optional Worker Loader support for sandboxed plugins.

The EmDash architecture is database/Portable Text centered. It does not
default to a Git-backed Markdown static publishing workflow.
