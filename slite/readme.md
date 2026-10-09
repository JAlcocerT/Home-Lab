---
source_code: https://github.com/miantiao-me/Slite
post: https://fossengineer.com/selfhosting-slite/
tags: ["url shortener", "link analytics", "docker", "sqlite", "duckdb"]
---

Slite is the local Docker sibling of Sink.

Mental model: Slite is the Sink-style app without Cloudflare D1/KV/Analytics/R2. It replaces those managed services with a local stack.

| Sink piece | Slite replacement |
| --- | --- |
| Cloudflare Workers | Node.js 24 / Nitro container |
| Cloudflare D1 | SQLite at `/data/slite.sqlite` |
| Cloudflare KV | In-memory process cache |
| Cloudflare Analytics Engine | DuckDB at `/data/analytics.duckdb` |
| Cloudflare R2 | Local filesystem under `/data/files/images` and `/data/backups` |
| Cloudflare Workers AI | Optional OpenAI-compatible provider via xsai |

It uses:

- one Node.js 24/Nuxt/Nitro process;
- SQLite at `/data/slite.sqlite` for authoritative link data;
- DuckDB at `/data/analytics.duckdb` for click analytics;
- local filesystem storage under `/data/files/images` and `/data/backups`;
- an in-memory rebuildable link cache.

Start it:

```bash
cp .env.sample .env
docker compose up -d
```

Open:

```text
http://localhost:5483/dashboard
```

Use `NUXT_SITE_TOKEN` from `.env` to sign in.

Do not run multiple Slite containers against the same `/data` volume. SQLite, DuckDB, and the in-memory cache are designed for one process per data directory.
