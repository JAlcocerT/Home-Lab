# BetterStatusPage

Single-container Home-Lab deployment of BetterStatusPage.

## Start

```bash
cp .env.sample .env
openssl rand -hex 32
```

Use one generated value for `JWT_SECRET` and another for `VAULT_ENCRYPTION_KEY`, then run:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

Open the setup wizard:

```text
http://192.168.1.2:3819/admin
```

Create the administrator account in the wizard. There is no default password. The public status page is at `http://192.168.1.2:3819/` after setup.

The first-run signup wizard is the intended onboarding path and worked cleanly in the local trial: enter the administrator email and password there rather than looking for seeded credentials.

Data is persisted in the `bsp_data` and `bsp_backups` Docker volumes. Do not run `docker compose down -v` unless you intend to delete the database and backups.
