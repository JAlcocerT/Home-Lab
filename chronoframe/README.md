---
source_code: https://github.com/HoshinoSuzumi/chronoframe
post: https://fossengineer.com/selfhosting-chronoframe-photo-gallery/
tags: ["photos", "gallery", "nuxt", "vue", "sqlite", "s3", "live-photos"]
---

ChronoFrame is a self-hosted photo gallery with EXIF processing, previews,
albums, map browsing, Live Photos, local storage, S3-compatible storage, and
OpenList support.

This Home-Lab profile uses the tested image digest and maps the UI to port
`3802`, because port `3000` is already used by another service on the host.

```bash
cp .env.sample .env
docker compose up -d
```

Open `http://192.168.1.2:3802/`. The first visit opens the onboarding wizard.
Create the administrator and choose local storage with `/app/data/storage`.
There is no universal default password in the current setup flow; choose it in
the wizard. Keep the complete `data/` directory for the SQLite database,
session secret, settings, originals and derived files.

The image is digest-pinned to the review pull from 2026-10-26. Check upstream
release notes before changing the digest; database migrations run at startup,
so back up `data/` before upgrades.
