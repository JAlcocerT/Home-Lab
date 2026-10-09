---
source_code: https://github.com/miantiao-me/Sink
post: https://fossengineer.com/selfhosting-sink-cloudflare/
tags: ["url shortener", "link analytics", "cloudflare", "d1", "kv"]
---

Sink is Cloudflare-native rather than a local Docker compose stack.

Current Sink uses:

- Cloudflare Workers for the app and redirects;
- Cloudflare D1 as the authoritative link database;
- Cloudflare KV as the redirect cache;
- optional Analytics Engine, R2, and Workers AI bindings.

There is no Home-Lab compose file here because the upstream project is designed around Cloudflare bindings. For a local Node/Docker deployment, check Sink's sibling project Slite instead.
