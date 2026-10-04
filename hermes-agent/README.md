# Hermes Agent

Minimal Docker Compose setup for Nous Research Hermes Agent.

Run the setup wizard first:

```bash
cp .env.sample .env
docker compose run --rm hermes-agent setup
```

Then start the long-running gateway:

```bash
docker compose up -d
```

All Hermes state is stored under `./data` by default. Do not run two Hermes
gateway containers against the same data directory at the same time.

This compose file pins `nousresearch/hermes-agent:v2026.6.5` instead of
`latest`. The API port binds to `127.0.0.1:8642` by default; change
`HERMES_API_BIND`, `HERMES_API_PORT`, and `API_SERVER_KEY` in `.env` before
exposing the OpenAI-compatible API through a reverse proxy.
