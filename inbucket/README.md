# Inbucket

Disposable webmail and email testing service with built-in SMTP, web UI, REST API, and POP3.

```bash
cp .env.sample .env
docker compose up -d
```

- Web UI: `http://localhost:9000`
- SMTP: `localhost:2500`
- POP3: `localhost:1100`

For another container in the same Compose network, use `SMTP_HOST=inbucket` and `SMTP_PORT=2500`.

The compose file stores messages in the `inbucket-storage` volume, keeps messages for 72 hours by default, and caps each mailbox at 300 messages.
