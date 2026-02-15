# Nextcloud Fresh Install — HTTPS behind Cloudflare Tunnels

Fix for the Nextcloud Desktop Client error:
> "Server URL does not start with HTTPS"

## Root Cause

Cloudflare Tunnels terminate SSL externally, so requests reach the Nextcloud container over plain HTTP. Nextcloud then generates `http://` URLs in API responses. The browser ignores this, but the **desktop client strictly rejects the mismatch**.

## Prerequisites

- Nextcloud data lives on a separate drive mounted at `/mnt/data1tb/`
- The drive **must** use a Linux-native filesystem (`ext4`, `xfs`, etc.) — `ntfs`/`fat32` won't support ownership/permissions

Verify filesystem type:

```bash
df -Th /mnt/data1tb
```

Verify the drive is in `/etc/fstab` (so it auto-mounts on reboot):

```bash
grep data1tb /etc/fstab
```

> [!WARNING]
> If the drive isn't in fstab, containers will silently write to your root disk at the mount point path.

---

## Step 1 — Stop and Remove Containers

```bash
cd /home/jalcocert/Desktop/Home-Lab/z-homelab-setup/evolution
docker compose -f 2602_docker-compose.yml down
```

## Step 2 — Wipe All Previous Nextcloud Data

```bash
sudo rm -rf /mnt/data1tb/nextcloud
```

## Step 3 — Recreate Directories with Correct Ownership

```bash
sudo mkdir -p /mnt/data1tb/nextcloud/html
sudo mkdir -p /mnt/data1tb/nextcloud/db
sudo chown -R 33:33 /mnt/data1tb/nextcloud/html    # UID 33 = www-data (Nextcloud)
sudo chown -R 1000:1000 /mnt/data1tb/nextcloud/db   # PUID/PGID for linuxserver MariaDB
```

## Step 4 — Docker Compose Changes

Three changes were applied to `2602_docker-compose.yml` in the `nextcloud-app` service:

| Change | Before | After | Why |
|--------|--------|-------|-----|
| `user` directive | `user: "1000:1000"` | *(removed)* | Entrypoint must run as root to set up www-data ownership |
| `OVERWRITEPROTOCOL` | *(missing)* | `https` | Forces Nextcloud to generate `https://` URLs |
| `OVERWRITECLIURL` | *(missing)* | `https://whatever.jalcocertech.com` | Canonical URL for client discovery |
| `NEXTCLOUD_TRUSTED_DOMAINS` | `http://192.168.1.12:8099` | `whatever.jalcocertech.com 192.168.1.12` | Must be bare hostnames, space-separated |

## Step 5 — Start Everything Fresh

```bash
cd /home/jalcocert/Desktop/Home-Lab/z-homelab-setup/evolution
docker compose -f 2602_docker-compose.yml up -d
docker compose -f 2602_docker-compose.yml logs nextcloud-app --tail 50
```

## Step 6 — Verify

Wait ~30 seconds for initial setup, then confirm:

```bash
# Check overwriteprotocol is set
docker exec -u www-data nextcloud php occ config:system:get overwriteprotocol
# Expected output: https

# Check containers are healthy
docker ps --filter "name=nextcloud"
```

Then connect with the Nextcloud Desktop Client using `https://whatever.jalcocertech.com`.

---

## Key Takeaway

Any Nextcloud behind a reverse proxy (Traefik, Cloudflare Tunnels, NGINX) that terminates SSL needs these environment variables set in docker-compose:

```yaml
- OVERWRITEPROTOCOL=https
- OVERWRITECLIURL=https://your.domain.com
```

And the container must **not** have `user:` set — let the entrypoint run as root so it can manage `www-data` permissions.

---

## TL;DR — What Actually Fixed It

The desktop client error was caused by **one missing environment variable**: `OVERWRITEPROTOCOL=https`. Cloudflare Tunnels strip SSL before the request hits the container, so Nextcloud thinks it's running on HTTP and returns `http://` URLs. The desktop client (unlike the browser) refuses to accept that.

The `user: "1000:1000"` line made things worse by breaking the entrypoint's ability to set file permissions, causing restart loops when trying to apply the fix via `occ`.

**The fix in two lines of docker-compose:**

```yaml
- OVERWRITEPROTOCOL=https
- OVERWRITECLIURL=https://whatever.jalcocertech.com
```

---

## Pro Tip: Starting Specific Services

If you only want to restart Nextcloud (and not everything else in the compose file), just add the service name to the end of the command:

```bash
# Start ONLY Nextcloud and its database
docker compose -f 2602_docker-compose.yml up -d nextcloud-app nextclouddb

# Start ONLY Jellyfin
docker compose -f 2602_docker-compose.yml up -d jellyfin

# Start ALL Media & Tools services (Everything EXCEPT Nextcloud)
docker compose -f 2602_docker-compose.yml up -d jellyfin metube navidrome qbittorrent prowlarr homepage-lite termix pigallery2 uptimekuma-monitoring neko logseq
```
