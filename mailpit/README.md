# Mailpit

Local SMTP catcher and web inbox for testing application emails.

```bash
docker compose up -d
```

- Web UI: `http://localhost:8025`
- SMTP: `localhost:1025`

For another container in the same Compose network, use `SMTP_HOST=mailpit` and `SMTP_PORT=1025`.
