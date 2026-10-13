# Folio

Git-native collaborative wiki with documents, whiteboards, tables, files,
offline editing, and MCP access for AI agents.

## Start

```bash
cp .env.sample .env
nano .env
docker compose up -d
```

Generate `POSTGRES_PASSWORD` once:

```bash
openssl rand -base64 32
```

`FOLIO_SECRET` can be left empty. Folio will generate one on first start and
store it in the `folio-data` volume. If you set it yourself, never rotate it
without planning because it encrypts saved Git tokens and personal AI keys.

## Access

```text
http://192.168.1.2:4870
```

The first account created in the browser becomes the instance administrator.

## Data to Back Up

Back up both:

- `folio-data`, which contains Git repositories, uploaded files, and the generated secret when `FOLIO_SECRET` is empty.
- `folio-pg`, or a logical `pg_dump`, which contains accounts, access rights, search/index data, and collaborative editing state.

Redis is transient and intentionally not persisted.
