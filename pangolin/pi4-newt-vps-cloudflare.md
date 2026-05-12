# Expose Pi Services Without Opening Router Ports

How to expose home services running on a Raspberry Pi 4 to the internet **without** forwarding any router port and **without** publishing the home IP in DNS, using Pangolin (server on a cheap VPS) + Newt (client on the Pi) + a Cloudflare-managed domain.

## How it works

```
Internet user
     │
     ▼
Cloudflare DNS  (*.example.com → VPS public IP, grey cloud)
     │
     ▼
VPS (public IP, runs pangolin + gerbil + traefik)
     ▲
     │ WireGuard tunnel (UDP 51820, initiated outbound from Pi)
     ▼
Pi  (home LAN, NAT'd, runs newt only)
     │
     ▼
Local services (Grafana, Vaultwarden, Home Assistant, etc.)
```

- The **Pi only makes outbound connections**. No inbound ports, no port forwarding, no UPnP.
- The **VPS is the only public IP** in DNS. The home WAN IP is never published.
- **CGNAT, dynamic home IP, double-NAT** — none of it matters.
- TLS certs are issued by Let's Encrypt on the VPS (Traefik handles renewal).
- Auth (SSO / password / PIN / OTP) is enforced by Pangolin before traffic ever reaches the Pi.

## What you need

| Thing | Notes |
|-------|-------|
| Domain on Cloudflare | Any registrar works; this guide uses Cloudflare DNS. |
| VPS with public IPv4 | 2 GB RAM is enough. Hetzner CX22 (~€4/mo), Netcup VPS 200 G11 (~€3/mo), OVH VPS Starter (~€3.5/mo), or Oracle Cloud Free (4 ARM cores / 24 GB, $0 when available). |
| Pi 4 (4 GB) | Raspberry Pi OS 64-bit. Docker or Podman installed. |
| 5 minutes on the router | Just to confirm the Pi has outbound internet. **No port forwards needed.** |

## Cost & exposure summary

| Asset | Public on internet? |
|-------|---------------------|
| Pi LAN IP | No |
| Home WAN IP | No |
| Router ports | **None opened** |
| VPS public IP | Yes (only this in DNS) |
| Service URLs | Yes, via `*.example.com` → VPS → tunnel → Pi |

---

## Part 1 — Cloudflare DNS

In Cloudflare dashboard for your zone, add:

| Type | Name | Content | Proxy status |
|------|------|---------|--------------|
| A | `pangolin` | `<VPS public IP>` | **DNS only (grey cloud)** |
| A | `*` | `<VPS public IP>` | **DNS only (grey cloud)** |

**Proxy must be OFF (grey cloud).** Reasons:

- Traefik on the VPS issues real Let's Encrypt certs via HTTP-01. Orange cloud breaks that challenge unless you switch to DNS-01.
- WireGuard (UDP 51820) cannot proxy through Cloudflare regardless.
- Orange cloud → 525 / 526 errors and broken renewals.

The wildcard record means every new resource (`grafana.example.com`, `vault.example.com`, …) works without touching DNS again.

---

## Part 2 — VPS: install Pangolin server

SSH into the VPS as a sudo user.

### 2.1 Open firewall

```bash
sudo ufw allow 22/tcp        # keep SSH
sudo ufw allow 80,443/tcp    # Traefik
sudo ufw allow 51820/udp     # Gerbil / WireGuard
sudo ufw enable
```

(If using cloud-provider firewall instead, open the same.)

### 2.2 Install Docker (if missing)

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker
```

### 2.3 Run the official installer

```bash
mkdir -p ~/pangolin && cd ~/pangolin
curl -fsSL https://digpangolin.com/get-installer.sh -o installer.sh
chmod +x installer.sh
sudo ./installer.sh
```

Answer prompts:

| Prompt | Answer |
|--------|--------|
| Base domain | `example.com` |
| Dashboard subdomain | `pangolin` (→ `pangolin.example.com`) |
| Admin email | real address (Let's Encrypt notices) |
| Enable open signup | `no` |
| Use Traefik | `yes` |
| Use CrowdSec | `no` (add later if wanted) |

Installer writes a real `docker-compose.yml` (pangolin + gerbil + traefik) plus `config/` directory.

### 2.4 Bring up

```bash
docker compose up -d
docker compose logs -f traefik
```

Watch for `obtained certificate`. If it fails, port 80 is not reachable from the internet — fix the cloud-provider firewall.

### 2.5 First login

Browse to `https://pangolin.example.com`:

1. Create the admin user.
2. Create an **Organization**.
3. Create a **Site** (give it a name like `home-pi`).
4. The dashboard now displays:
   - `PANGOLIN_ENDPOINT` (= `https://pangolin.example.com`)
   - `NEWT_ID`
   - `NEWT_SECRET`

   Copy them. They go on the Pi next.

---

## Part 3 — Pi: install Newt client

SSH into the Pi. Assuming this repo is already cloned at `~/Home-Lab/pangolin`.

### 3.1 Set aside the broken compose

The `docker-compose.yml` in the repo is incorrect for this use case (single-container Pangolin, missing dependencies). Rename it:

```bash
cd ~/Home-Lab/pangolin
mv docker-compose.yml docker-compose.yml.broken.bak
```

### 3.2 Write the Newt compose

Create a new `docker-compose.yml`:

```yaml
services:
  newt:
    image: fosrl/newt:latest
    container_name: newt
    restart: unless-stopped
    environment:
      - PANGOLIN_ENDPOINT=https://pangolin.example.com
      - NEWT_ID=replace-with-id-from-dashboard
      - NEWT_SECRET=replace-with-secret-from-dashboard
    # No ports published — Newt is outbound-only.
```

Replace the three placeholders with the values from the Pangolin dashboard.

### 3.3 Start it

Docker:

```bash
docker compose up -d
docker logs -f newt
```

Podman:

```bash
podman compose up -d
podman logs -f newt
```

Look for `tunnel established` / `registered with pangolin`. The Site indicator in the dashboard flips to **Online** within seconds.

The Pi now has an outbound WireGuard tunnel to the VPS. Nothing was changed on the router.

---

## Part 4 — Expose a local service

Example: Grafana running on the Pi at `http://192.168.1.50:3000`.

In the Pangolin dashboard:

1. Open the Site → **Resources** → **Add Resource**.
2. **Subdomain**: `grafana` → public URL becomes `https://grafana.example.com`.
3. **Target**: `http://192.168.1.50:3000`.
   - This must be reachable **from the Pi**.
   - If the service is on the Pi itself, it must bind to `0.0.0.0`, not `127.0.0.1`.
4. **Auth**: pick one (SSO, password, PIN, OTP, or public).
5. Save.

Visit `https://grafana.example.com`. You will see:

- A real Let's Encrypt cert (issued on the VPS).
- The Pangolin auth page (unless you picked public).
- After auth, the Grafana UI, served through the WireGuard tunnel to the Pi.

Repeat for every service. Wildcard DNS already covers all of them.

---

## Survival commands (Pi side)

```bash
docker logs -f newt                       # tunnel log
docker compose restart                    # bounce Newt
docker compose pull && docker compose up -d   # update Newt
docker compose down                       # stop
```

Newt has no local state — wiping the container loses nothing.

## Survival commands (VPS side)

```bash
docker compose logs -f pangolin
docker compose logs -f gerbil
docker compose logs -f traefik
docker compose pull && docker compose up -d
tar czf pangolin-backup-$(date +%F).tgz config/   # back up SQLite + certs + yml
```

Back up `config/` regularly. That directory is the entire state of the Pangolin server.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Newt: `connect: connection refused` | VPS not reachable | Verify `PANGOLIN_ENDPOINT` URL, DNS resolves to VPS IP, UDP 51820 open on VPS firewall. |
| Site stays Offline | Wrong `NEWT_ID` / `NEWT_SECRET` | Regenerate from dashboard, redeploy Newt. |
| Browser: 502 Bad Gateway on resource | Newt OK, but cannot reach target | From the Pi run `curl -v http://<target-ip>:<port>`. Service may bind to `127.0.0.1` only, or LAN IP wrong. |
| Browser: cert warning / `NET::ERR_CERT_AUTHORITY_INVALID` | Let's Encrypt failed on VPS | Cloudflare proxy is ON (must be grey cloud), or port 80 blocked on VPS. Check `traefik` log. |
| Cloudflare 525 / 526 | Cloudflare proxy ON in front of Traefik | Switch the records to grey cloud (DNS only). |
| Newt restarts loop, `iptables` errors | Pi running nftables backend | `sudo update-alternatives --set iptables /usr/sbin/iptables-legacy`, reboot. |
| Resource works internally but not externally | Wildcard DNS missing | Add `*` A record to VPS IP in Cloudflare, grey cloud. |

---

## Why not Cloudflare Tunnel instead?

Cloudflare Tunnel does the same outbound-only trick. Pangolin's value over it:

- Self-hosted, no third-party dependency for the data plane.
- Built-in auth methods (SSO, password, PIN, OTP) at the gateway, no per-app config.
- TCP/UDP forwarding (not just HTTP), since it tunnels at WireGuard level.
- One dashboard, multiple sites, multiple resources — explicit org/RBAC model.

Cloudflare DNS is still useful here just for the records pointing at the VPS.

---

## References

- Pangolin docs: https://docs.pangolin.net/
- Newt install: https://docs.pangolin.net/manage/sites/install-site
- Pangolin source: https://github.com/fosrl/pangolin
- Newt source: https://github.com/fosrl/newt
- Installer host: https://digpangolin.com/get-installer.sh
