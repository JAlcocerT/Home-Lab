---
tags: ["DNS", "Pi-hole"]
source_code: https://github.com/pi-hole/docker-pi-hole
---


* https://github.com/pi-hole/docker-pi-hole/releases
* https://hub.docker.com/r/pihole/pihole/tags


# ⚠️ Fixing DNS (Port 53 Conflict)

If your system uses `systemd-resolved` (Ubuntu/Debian usually do), it binds port `53`, preventing Pi-hole from starting.

**Steps to fix:**

```bash
# 1. Stop and disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl status systemd-resolved

# 2. Manually set DNS to Cloudflare (to keep internet working)
sudo rm /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf #will change this nameserver 127.0.0.53

# 1. Enable and start the service
#sudo systemctl enable systemd-resolved
#sudo systemctl start systemd-resolved
```

Once Pi-hole is running, you can optionally set `nameserver 127.0.0.1` to use yourself!

# 🚀 Running Pi-hole

```bash
docker compose -f piholev6-docker-compose.yml up -d
docker compose -f piholev6-docker-compose.yml logs -f
```

Then just go to `http://localhost:500/admin/login`, use the `FTLCONF_webserver_api_password` as password.

# 🛑 Recommended Blocklists

Yes, adding more blocklists makes sense! 

You can add these in the Web UI: **Adlists** -> **Add a new adlist**.

**1. The Big Blocklist Collection (OISD.nl):**
*   **Big (Full):** `https://big.oisd.nl/` (Catches almost everything, very safe)
*   **Small (Basic):** `https://small.oisd.nl/` (Focuses on main ads/trackers)

**2. Firebog Ticked Lists (Green/Safe):**
These are highly recommended and rarely break sites:
*   `https://v.firebog.net/hosts/AdguardDNS.txt`
*   `https://v.firebog.net/hosts/Admiral.txt`
*   `https://v.firebog.net/hosts/Easylist.txt`
*   `https://v.firebog.net/hosts/Prigent-Ads.txt`

*(The default StevenBlack list is already included)*