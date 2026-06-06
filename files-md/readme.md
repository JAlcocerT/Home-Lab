---
post: https://fossengineer.com/files-md-local-first-markdown-notes/
source_code: https://github.com/zakirullin/files.md
official_docs: https://files.md/
tags: ["Markdown Notes", "Productivity", "Knowledge Management", "Self-Hosting"]
---

Files.md is a local-first Markdown notes app with an optional self-hosted Go sync server.

```sh
cp .env.sample .env
docker compose up -d --build
docker compose logs -f
```

Open `http://localhost:8088`.

The compose file builds from the upstream GitHub repository because Files.md ships a Dockerfile but does not currently document a prebuilt public container image. The build context is pinned to the commit tested for the Foss Engineer post.

By default the service binds to `127.0.0.1:8088`. Change `FILES_MD_BIND`, `FILES_MD_PORT`, and `FILES_MD_PUBLIC_URL` in `.env` when exposing it through a reverse proxy.
