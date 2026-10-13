---
source_code: https://github.com/manyfold3d/manyfold
tags: ["3D printing", "model library", "Rails", "self-hosting"]
---

# Manyfold

Self-hosted digital asset manager for 3D print files.

```bash
cp .env.sample .env
openssl rand -hex 64
```

Put the generated value into `SECRET_KEY_BASE`, then start:

```bash
docker compose up -d
```

Local URL:

```text
http://192.168.1.2:3820/
```

This compose uses the all-in-one `manyfold-solo` image. App state and the
SQLite database live in `./config`; the model library lives in `./models` and is
mounted at `/models` inside the container. Add `/models` as a library path from
the Manyfold UI.

The compose includes a one-shot `init-permissions` service so the app user can
write SQLite sidecar files and model-library content on bind mounts.

For a public deployment, put Manyfold behind HTTPS and set `PUBLIC_HOSTNAME` to
the external hostname without `https://`.
