# DBackup

Self-hosted database and file backup automation.

## Start

```bash
cp .env.sample .env
nano .env
docker compose up -d
```

Generate the two required secrets once and keep them:

```bash
openssl rand -hex 32
openssl rand -base64 32
```

Do not regenerate `ENCRYPTION_KEY` after you have configured sources,
destinations, credentials, or encryption keys. Losing it makes stored secrets
unreadable.

## Access

```text
http://192.168.1.2:3802
```

The first account created in the UI becomes the administrator.

## Volumes

- `./data:/data` stores the SQLite database, app storage, and certificates.
- `./backups:/backups` is available for local backup destinations.
- `./tmp:/tmp` gives running backups staging space outside the container layer.

The Docker socket is commented out by default. Mount it only if you plan to use
DBackup's Docker volume source.

The sample keeps DBackup's documented default `PUID`/`PGID` of `1001`. Change
them only if you need bind-mounted files owned by a different host user.
