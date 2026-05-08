# Pangolin on Raspberry Pi 4 (4GB) — Step-by-Step

## Will it run?

Yes. The `ghcr.io/fosrl/pangolin` and `fosrl/newt` images both publish `linux/arm64` manifests. A Pi 4 with 4 GB RAM is far more than enough — both binaries are Go and idle around ~100 MB combined.

## Pick your role first

Pangolin is a two-sided system:

| Side | Component | Where it normally lives |
|------|-----------|-------------------------|
| **Server** (control plane + reverse proxy + WireGuard endpoint) | `pangolin` + `gerbil` + `traefik` | A **VPS with a public IP** and ports 80/443/51820 reachable |
| **Client** (tunnel agent that exposes home services) | `newt` | Your **home node** (this Pi) |

Most home-lab setups put the **server on a cheap VPS** (Hetzner, Netcup, OVH, etc.) and run **Newt on the Pi**. That is the path this guide takes.

If your Pi has a real public IPv4 with the required ports forwarded and you want the Pi to *be* the Pangolin server, jump to the [Server on Pi](#optional-running-the-pangolin-server-on-the-pi) section.

---

## Part A — Newt client on the Pi (recommended)

### Prerequisites

- Pi 4 (4 GB) running Raspberry Pi OS 64-bit (or any arm64 Linux)
- Docker **or** Podman installed (you already have both)
- A working Pangolin server reachable at `https://your-pangolin-domain.example.com`
- A **Site** created in the Pangolin dashboard. After creating the site, the dashboard shows three values you must copy:
  - `PANGOLIN_ENDPOINT`
  - `NEWT_ID`
  - `NEWT_SECRET`

### Step 1 — Make a working directory

```bash
mkdir -p ~/pangolin-newt
cd ~/pangolin-newt
```

### Step 2 — Create `docker-compose.yml`

```yaml
services:
  newt:
    image: fosrl/newt:latest
    container_name: newt
    restart: unless-stopped
    environment:
      - PANGOLIN_ENDPOINT=https://your-pangolin-domain.example.com
      - NEWT_ID=replace-with-id-from-dashboard
      - NEWT_SECRET=replace-with-secret-from-dashboard
    # Newt only needs outbound connections — no ports to publish.
```

Replace the three env values with what the dashboard gave you.

### Step 3 — Start it

Docker:

```bash
docker compose up -d
docker logs -f newt
```

Podman (rootless works fine):

```bash
podman compose up -d
podman logs -f newt
```

You should see lines like `tunnel established` / `registered with pangolin`. The site indicator in the dashboard should flip to **Online** within a few seconds.

### Step 4 — Expose a local service

In the Pangolin dashboard:

1. Open your Site → **Resources** → **Add Resource**.
2. Pick a subdomain (e.g. `grafana.example.com`).
3. Target = the Pi's LAN IP and port (e.g. `http://192.168.1.50:3000`). Newt forwards from the tunnel to this address, so it must be reachable **from the Pi**.
4. Pick an auth method (SSO / password / PIN / public).
5. Save. Visit the subdomain — TLS comes from Traefik on the server side.

### Step 5 — Updates

```bash
docker compose pull
docker compose up -d
```

### Troubleshooting

- **`tunnel: connect: connection refused`** → server not reachable; check `PANGOLIN_ENDPOINT` URL, DNS, and that the VPS has UDP 51820 open.
- **Site stays Offline** → wrong `NEWT_ID`/`NEWT_SECRET`. Regenerate from dashboard.
- **Resource 502s** → Newt reaches Pangolin but cannot reach the target. From the Pi run `curl -v http://<target-ip>:<port>`. Fix LAN routing or target container binding (`0.0.0.0`, not `127.0.0.1`).
- **Podman + SELinux** → add `:Z` if you ever mount a volume.

---

## Optional — Running the Pangolin *server* on the Pi

Only do this if **all** of the following are true:

- Pi has a public IPv4 (no CGNAT) **or** you have proper IPv6 + port forwarding.
- Router forwards TCP **80**, TCP **443**, and UDP **51820** to the Pi.
- A domain with a wildcard A record (`*.example.com`) points at that public IP.

The full server stack is **Pangolin + Gerbil + Traefik**, not the single container shown in the existing `docker-compose.yml` in this folder (that file is incorrect — see your `readme.md` review).

### Easiest path: official installer

```bash
curl -fsSL https://digpangolin.com/get-installer.sh -o installer.sh
chmod +x installer.sh
sudo ./installer.sh
```

The installer asks for the base domain, an admin email (for Let's Encrypt), and writes a working `docker-compose.yml` plus `config/config.yml` and the Traefik config. It pulls arm64 images automatically on the Pi.

### After install

- Dashboard: `https://pangolin.example.com` (or whatever subdomain you picked).
- Create your first user, then a Site, then point a Newt agent (on another machine, **not** this Pi if the Pi is also the server) at it.
- Data lives in `./config/` — back that directory up.

### Resource notes for Pi-as-server

- 4 GB is enough for a personal stack (a handful of sites, a dozen resources). Watch `docker stats` if you push past that.
- Put `./config/` on the SD card's most stable partition or, better, an external SSD over USB 3 — Traefik + SQLite do constant small writes and SD cards die.
- Keep an eye on the SQLite DB at `config/db/db.sqlite`; back it up with the rest of `./config/`.

---

## Quick reference

| Task | Command |
|------|---------|
| Logs | `docker logs -f newt` |
| Restart | `docker compose restart` |
| Update | `docker compose pull && docker compose up -d` |
| Stop | `docker compose down` |
| Wipe state (Newt only — no local state to lose) | `docker compose down && docker compose up -d` |

## References

- Pangolin docs: https://docs.pangolin.net/
- Newt install: https://docs.pangolin.net/manage/sites/install-site
- Source: https://github.com/fosrl/pangolin
- Newt source: https://github.com/fosrl/newt
