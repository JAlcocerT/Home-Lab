# MailDev

Local SMTP server and browser inbox for development email testing.

```bash
cp .env.sample .env
docker compose up -d
```

- Web UI: `http://localhost:1080`
- SMTP: `localhost:1025`

For another container in the same Compose network, use `SMTP_HOST=maildev` and `SMTP_PORT=1025`.

The compose file keeps the newest `1000` messages by default. Captured mail is for development testing and is not intended as durable storage.
