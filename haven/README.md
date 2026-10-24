# Haven

Private, self-hosted Discord alternative with channels, DMs, voice, screen sharing, a browser UI, native clients, and SQLite persistence.

## Start

```bash
cp .env.sample .env
openssl rand -hex 32
```

Put the generated value in `JWT_SECRET`, then run:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

Open the LAN UI at `http://192.168.1.2:3820`.

The first account must use the configured `ADMIN_USERNAME` (default `admin`) to receive administrator privileges. Choose its password during registration; there is no universal default password.

This Home-Lab profile uses plain HTTP for convenient LAN testing. Use HTTPS through Haven's generated certificate or a reverse proxy before enabling browser voice, screen sharing, push notifications, or public access. For users across different networks, configure TURN/coturn and expose relay ports deliberately.

The `haven_data` volume contains the SQLite database, certificates, configuration, uploads, and backups. Do not run `docker compose down -v` unless you intend to delete the server data.
