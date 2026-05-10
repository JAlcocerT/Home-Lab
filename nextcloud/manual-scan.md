# Nextcloud Manual File Scan

Use this when you drop files directly into the data directory instead of uploading via the UI or a client.

## Workflow

### 1. Copy files into the data directory

The Nextcloud data directory (as configured in this repo) is:

```
/home/jalcocert/Docker/nextcloud/html/data/<username>/files/
```

Example for a 1TB copy:

```bash
rsync -av --progress /source/path/ /home/jalcocert/Docker/nextcloud/html/data/<username>/files/
```

### 2. Fix ownership before scanning

Files must be owned by `www-data` inside the container, otherwise the scan finds them but marks them inaccessible.

```bash
docker exec nc chown -R www-data:www-data /var/www/html/data
```

Or from the host (same effect):

```bash
sudo chown -R www-data:www-data /home/jalcocert/Docker/nextcloud/html/data
```

### 3. Run the file scan

Scan all users:

```bash
docker exec -u www-data nc php occ files:scan --all
```

Scan a specific user only:

```bash
docker exec -u www-data nc php occ files:scan <username>
```

For large datasets run inside `screen` or `tmux` so an SSH disconnect does not kill it:

```bash
screen -S ncscan
docker exec -u www-data nc php occ files:scan --all
# Ctrl+A D to detach, screen -r ncscan to reattach
```

### 4. Generate previews (optional)

The scan indexes files but does not generate thumbnails. Trigger separately:

```bash
docker exec -u www-data nc php occ preview:generate-all
```

---

## Detecting errors

### During the scan

The scan prints a summary line at the end:

```
+---------+-------+--------------+
| Folders | Files | Elapsed time |
+---------+-------+--------------+
| 1234    | 56789 | 00:04:23     |
+---------+-------+--------------+
```

Any file it could not process is printed inline as a warning. Pipe output to a log file to review after:

```bash
docker exec -u www-data nc php occ files:scan --all 2>&1 | tee /tmp/ncscan.log
grep -i 'error\|warn\|exception\|could not' /tmp/ncscan.log
```

### Check the Nextcloud log

The main Nextcloud log lives inside the container at `/var/www/html/data/nextcloud.log` (also accessible on the host at the mapped data path).

```bash
# Last 100 lines
docker exec nc tail -n 100 /var/www/html/data/nextcloud.log

# Filter for errors only
docker exec nc grep '"level":3\|"level":4' /var/www/html/data/nextcloud.log | tail -50
```

Level 3 = error, level 4 = fatal.

### Common UI complaints and fixes

| UI message | Likely cause | Fix |
|---|---|---|
| "File not found" | Ownership wrong, www-data can't read it | `chown -R www-data:www-data` on the data dir |
| "You don't have permission" | Same as above, or SELinux/AppArmor | Check `ls -la` on the file, fix ownership |
| Files visible in UI but can't download | Scan ran before chown | Re-chown then rescan |
| Files not appearing at all | Scan not run after copy | Run `occ files:scan` |
| "Storage is temporarily not available" | DB or container restart mid-scan | Check `docker logs nc`, rerun scan |
| Broken previews / missing thumbnails | Preview generation not triggered | Run `occ preview:generate-all` |
| Size mismatch in UI vs disk | Scan interrupted | Rerun scan, check `occ files:cleanup` |

### Check for inconsistencies in the DB

```bash
docker exec -u www-data nc php occ files:scan --all --unscanned
docker exec -u www-data nc php occ files:cleanup
```

`files:cleanup` removes DB entries for files that no longer exist on disk — useful after deleting files outside Nextcloud.

### Check encryption status before copying

If server-side encryption is on, files dropped directly are not encrypted and will not be readable via the UI:

```bash
docker exec -u www-data nc php occ encryption:status
```

If it shows `enabled: true`, disable encryption first or use the proper migration path.

### Full maintenance mode scan (safest for large migrations)

Putting Nextcloud in maintenance mode prevents users from hitting inconsistent state while the scan runs:

```bash
docker exec -u www-data nc php occ maintenance:mode --on
docker exec -u www-data nc php occ files:scan --all 2>&1 | tee /tmp/ncscan.log
docker exec -u www-data nc php occ maintenance:mode --off
```
