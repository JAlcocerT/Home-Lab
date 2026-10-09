# Slash

Self-hosted shortcut and link-sharing app.

```bash
cp .env.sample .env
docker compose up -d
```

Open Slash at `http://localhost:5231` or replace `localhost` with the host IP.

The default compose uses Slash's built-in SQLite database under the `slash_data` Docker volume. Slash also supports PostgreSQL via `SLASH_DRIVER=postgres` and `SLASH_DSN=...`, but that is not required for a small home-lab deployment.
