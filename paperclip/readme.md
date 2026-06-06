# Paperclip

Paperclip is a self-hosted control plane for coordinating AI agents as a company: org chart, issues, goals, budgets, heartbeats, approvals, workspaces, and audit logs.

## Start

Copy the sample environment file and set real secrets:

```bash
cp .env.sample .env
```

Then start the stack:

```bash
docker compose up --build -d
```

Open:

```text
http://127.0.0.1:3100
```

## Notes

- This Compose file builds Paperclip from the public GitHub repository.
- The web UI is bound to localhost by default. Set `PAPERCLIP_BIND=0.0.0.0` only behind proper network controls.
- `BETTER_AUTH_SECRET` must be a long random value before first real use.
- `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` are optional and only needed for matching agents.
- Paperclip telemetry is disabled by default in this Home-Lab snippet.
- App state lives in the `paperclip-data` volume and PostgreSQL data lives in `paperclip-db`.

## Tested Locally

The upstream Compose configuration was validated with Docker Compose on a Linux host. The full image build and first-admin browser flow were not run during the initial article draft because the repository build is large and installs multiple local agent runtimes.
