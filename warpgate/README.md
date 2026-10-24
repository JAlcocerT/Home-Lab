# Warpgate

Self-hosted Rust bastion and transparent proxy for SSH, HTTPS, Kubernetes, MySQL, PostgreSQL, RDP, and VNC. It includes a browser admin UI, native-client support, TOTP, OpenID Connect, brute-force protection, access assignments, and optional session recording. The profile uses the verified image digest whose binary reports Warpgate v0.30.0; the registry does not publish a matching `v0.30.0` tag.

## Start

```bash
cp .env.sample .env
docker compose pull
docker compose run --rm warpgate setup
docker compose up -d
docker compose ps
```

The interactive setup asks whether to record sessions and creates the admin password. There is no universal default password. The first setup also generates the SQLite database, TLS certificate, and SSH keys inside the `warpgate_data` volume.

Open the LAN admin UI at:

```text
https://192.168.1.2:3888
```

The certificate is self-signed until you configure a trusted certificate or reverse proxy, so the browser will show a warning during LAN testing.

## Ports

| Host port | Warpgate listener | Purpose |
| ---: | ---: | --- |
| 3222 | 2222 | SSH |
| 3888 | 8888 | HTTPS admin and browser UI |
| 38443 | 8443 | Kubernetes |
| 36306 | 33306 | MySQL |
| 35432 | 55432 | PostgreSQL |
| 33389 | 3389 | RDP |
| 35900 | 5900 | VNC |

The setup-generated configuration enables SSH, Kubernetes, MySQL, and PostgreSQL by default. RDP and VNC remain disabled until enabled in Warpgate's configuration. Do not expose unused protocol ports beyond the trusted network.

## Data and upgrades

The `homelab_warpgate_data` volume contains the database, certificates, keys, configuration, logs, and recordings. Back it up before upgrades. Do not run `docker compose down -v` unless you intend to delete all Warpgate state.
