# ha.mr

Static URL compressor and QR code optimizer.

This deployment serves the static site with Nginx. The `site/` files were copied from upstream commit `af23d13ed488df891f65cf4df18c474859cb5e64`.

## Start

```bash
cp .env.sample .env
docker compose up -d --build
```

Default local URL:

```text
http://localhost:8790
```

For LAN access, open:

```text
http://192.168.1.2:8790
```

For public use, put it behind HTTPS with a reverse proxy or deploy the static files to Cloudflare Pages.

## Notes

`ha.mr` is not a normal database-backed shortener. It compresses the target URL into the generated link itself. There is no database, login, analytics, or stored slug table.
