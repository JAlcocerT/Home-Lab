# Nextcloud Recovery Notes

## What Happened

The old Nextcloud instance lives on `/mnt/data1tb/nextcloud` and is exposed
through `nube.jalcocertech.com`.

The failure mode was the data disk not being mounted when the old container
started. Docker then used the empty directory that existed on the root
filesystem at `/mnt/data1tb`, which made the instance look fresh or broken.

## Current Instances

- Old instance:
  - container: `nextcloud`
  - port: `8099`
  - hostname: `nube.jalcocertech.com`
- Sync instance:
  - container: `nextcloud-sync`
  - port: `8069`
  - hostname: `sync.jalcocertech.com`

## Health Checks

```bash
findmnt /mnt/data1tb
docker exec nextcloud php /var/www/html/occ status
docker exec nextcloud-sync php /var/www/html/occ status
docker exec nextcloud php /var/www/html/occ config:system:get trusted_domains
docker exec nextcloud-sync php /var/www/html/occ config:system:get trusted_domains
```

Expected:
- `nextcloud` should report `installed: true`
- `nextcloud-sync` should report `installed: true`
- `nextcloud` should accept `nube.jalcocertech.com`
- `nextcloud-sync` should accept `sync.jalcocertech.com`

## Preventing the Mount Problem

### Verify the mount

```bash
findmnt /mnt/data1tb
df -hT /mnt/data1tb
lsblk -f
```

### Keep it in fstab

Use the UUID entry so the mount comes back automatically on reboot:

```fstab
UUID=828a9077-86b9-4ab6-8761-cd735fa5533e /mnt/data1tb ext4 defaults,nofail,x-systemd.automount 0 2
```

### Make the stack wait for the mount

If the old Nextcloud stack is started through `systemd`, add:

```ini
[Unit]
Requires=docker.service
RequiresMountsFor=/mnt/data1tb
After=docker.service network-online.target local-fs.target
```

Example service:

```ini
[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/jalcocert/Home-Lab/z-homelab-setup/evolution
ExecStart=/usr/bin/docker compose -f 2605_docker-compose.yml up -d nextcloud-app nextclouddb
ExecStop=/usr/bin/docker compose -f 2605_docker-compose.yml down
```

## HTTPS Behind Cloudflare Tunnel

If the instance is behind a tunnel or reverse proxy, Nextcloud must generate
HTTPS URLs:

```bash
docker exec nextcloud php /var/www/html/occ config:system:get overwriteprotocol
docker exec nextcloud php /var/www/html/occ config:system:get overwrite.cli.url
```

If needed:

```bash
docker exec nextcloud php /var/www/html/occ config:system:set overwriteprotocol --value="https"
docker exec nextcloud php /var/www/html/occ config:system:set overwrite.cli.url --value="https://nube.jalcocertech.com"
```

## Docker Compose Reminder

For the old instance, do not route the `nube` hostname to the sync stack.
The old stack is the one that should receive `nube.jalcocertech.com`.

## Recovery Checklist

1. Confirm `/mnt/data1tb` is mounted.
2. Start or restart the old Nextcloud containers.
3. Verify `occ status` reports `installed: true`.
4. Verify `trusted_domains` includes `nube.jalcocertech.com`.
5. Verify the tunnel or proxy points `nube.jalcocertech.com` to the old stack.

