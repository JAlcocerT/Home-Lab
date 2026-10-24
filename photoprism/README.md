# PhotoPrism

Self-hosted, privacy-focused photo and video management with search, labels, face recognition, maps, RAW/video support, WebDAV, PWA access, and optional AI integrations.

## Start

```bash
cp .env.sample .env
# Replace all password values in .env.
mkdir -p originals import storage
docker compose pull
docker compose up -d
docker compose ps
```

Open the LAN UI at:

```text
http://192.168.1.2:3840
```

The initial admin username is `admin` unless changed in `.env`; the password is the value chosen in `PHOTOPRISM_ADMIN_PASSWORD`. There is no universal default password.

Put photos and videos under `originals/`, or set `PHOTOPRISM_ORIGINALS_PATH` to an existing library. Use `import/` for files that PhotoPrism should copy into the originals library. PhotoPrism stores its index, thumbnails, sidecars, backups, and configuration under `storage/`; the MariaDB data is kept in the `homelab_photoprism_database` volume.

This profile uses HTTP for trusted-LAN testing. Use HTTPS through PhotoPrism's TLS settings or a reverse proxy before public access, and update `PHOTOPRISM_SITE_URL` to the URL users actually open. PWA installation and browser features work best in a secure context.

Do not run `docker compose down -v` unless you intend to delete the MariaDB volume. Back up the originals, the `storage/` directory, and the database volume together.
