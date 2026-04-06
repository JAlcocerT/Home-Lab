# Nextcloud Desktop Client: "Server URL does not start with HTTPS"

## Problem

The Nextcloud **desktop client (Windows)** refused to connect, complaining that the server's returned URLs don't start with `https://`, even though the login URL was `https://nube.jalcocertech.com`.

## Root Cause

Nextcloud runs in a Docker container (`nextcloud`) behind **Cloudflare Tunnels**. The tunnel terminates SSL externally, so the request reaching the container is plain HTTP. Nextcloud sees HTTP and generates `http://` URLs in its API responses. The browser handles this silently, but the **desktop client strictly rejects the mismatch**.

## Fix Applied

### Step 1 — Tell Nextcloud to force HTTPS in all generated URLs

```bash
docker exec -u www-data nextcloud php occ config:system:set overwriteprotocol --value="https"
```

### Step 2 — Permission errors appeared

`config.php: Permission denied` — so we fixed ownership:

```bash
docker exec -u root nextcloud chown -R www-data:www-data /var/www/html/config
docker exec -u root nextcloud chown -R www-data:www-data /var/www/html/data
```

### Step 3 — Container entered a restart loop

`nextcloud-init-sync.lock: Permission denied` — so we couldn't use `docker exec`. We used a temporary Alpine container to fix permissions from outside:

```bash
docker stop nextcloud
docker run --rm --volumes-from nextcloud alpine sh -c "chown -R 33:33 /var/www/html && chmod -R 755 /var/www/html && echo 'Fix Complete'"
docker start nextcloud
```

> [!NOTE]
> UID `33` is `www-data` in Debian-based Nextcloud images. If using bind mounts, you may also need to fix permissions on the **host** directory directly.

## Key Takeaway

Any Nextcloud behind a reverse proxy (Traefik, Cloudflare Tunnels, NGINX) that terminates SSL needs `overwriteprotocol` set to `https` in `config.php` for desktop/mobile clients to work.
