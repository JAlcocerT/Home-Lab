# Using multiple Docker Compose files (base + local overrides)

- __Why__: Separate environment-specific settings from a clean base. Keep production-safe defaults in a base file, and put machine-specific/dev tweaks in a local override file.

## Typical layout

- Base (commit this): `compose.yml` (or `docker-compose.yml`)
- Local overrides (gitignore this): `compose.local.yml`
- Optional prod overrides: `compose.prod.yml`

## How merging works

Compose merges files left-to-right; later files override earlier ones.

```bash
docker compose -f compose.yml -f compose.local.yml up -d
# base first, local last (local wins)
```

- Scalars (e.g., image, command) are replaced by the later file.
- Maps (e.g., environment) are merged; conflicting keys use the later value.
- Arrays (e.g., ports, volumes) are generally replaced entirely unless keys allow merging.

## What to keep where

- __Base (`compose.yml`)__
  - Images and tags you want everywhere
  - Core env vars (non-secret), healthchecks, `depends_on`
  - Networks, container names, profiles

- __Local (`compose.local.yml`)__
  - Host-specific bind mounts (absolute paths under your home or /srv)
  - Alternative host ports (avoid collisions)
  - Local-only env (UID/GID, ROOT_URL, debug flags)
  - Extra dev services or tooling

## Example (Gitea)

Base `compose.yml`:

```yaml
services:
  gitea-server:
    image: docker.gitea.com/gitea:1
    environment:
      - GITEA__database__DB_TYPE=mysql
      - GITEA__database__HOST=gitea-db:3306
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=gitea
    depends_on:
      gitea-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/ || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 20s

  gitea-db:
    image: mysql:9.0
    environment:
      - MYSQL_ROOT_PASSWORD=gitea
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 10s
```

Local override `compose.local.yml`:

```yaml
services:
  gitea-server:
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__server__ROOT_URL=http://192.168.1.11:3033/
    ports:
      - "3033:3000"
      - "2234:22"
    volumes:
      - /srv/confs/gitea:/data

  gitea-db:
    volumes:
      - /srv/databases/gitea/mysql:/var/lib/mysql
```

Run locally:
```bash
docker compose -f compose.yml -f compose.local.yml up -d
```

## Tips

- __Order matters__: base first, overrides last.
- __Git hygiene__: commit base; gitignore locals.
- __.env files__: use `.env` (committed) and `.env.local` (ignored) for secrets/paths.
- __Profiles__: alternatively, enable optional services via `profiles` to avoid extra files.

## Summary

Use multiple files to keep production-safe defaults in the base and machine-specific/dev settings in local overrides. This improves portability, reduces merge conflicts, and prevents leaking local-only config into CI/CD.
