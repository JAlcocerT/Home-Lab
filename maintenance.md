# Docker Home-Lab Maintenance

Utility commands to keep your server lean and your disk space free.

## 1. Check Space Usage

Review how much space is being used by images, containers, and volumes.

```bash
docker system df
```

## 2. Safe Cleanup

Removes only "dangling" data (untagged images and stopped containers).

```bash
docker system prune
```

### 2.1 Stopping and Removing Containers
If you have running containers you no longer need:
```bash
# Stop a container
docker stop <container_name>

# Remove a container (to free up space)
docker rm <container_name>

# Stop and Remove in one go
docker rm -f <container_name>
```

## 3. Full Cleanup (The ~50GB fix)
Removes **all** unused images, stopped containers, and build cache.

```bash
docker system prune -a
```

## 4. Volume Cleanup (The 20GB fix)
Removes all local volumes NOT used by at least one container.

**Safety Check:** List all volumes that will be deleted:

```bash
docker volume ls -f dangling=true
```

**Normal Cleanup:** (Only handles anonymous volumes)

```bash
docker volume prune
```

**Forced Cleanup:** (Handles ALL dangling volumes, including named/orphaned ones)

```bash
docker volume rm $(docker volume ls -q -f dangling=true)
```

**Note:** Since most of your data is mapped to absolute paths on your Desktop (like `/home/jalcocert/Desktop/...`), those files are **perfectly safe**. This command only deletes internal Docker volumes that are no longer needed.

## 5. Inspection Commands (Find the Bulky ones)

See which running containers are using the most space (writable layer + image size):

```bash
docker ps -s --format "table {{.Names}}\t{{.Image}}\t{{.Size}}"
```

See all images sorted by size:

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -hk 3 -r
```

## 6. Folder Size Investigation (Find the Spacewheelers)

Find the top 50 biggest folders on a specific drive/path:

```bash
sudo du -h /path/to/search | sort -hr | head -n 50
#df -h /mnt/data2tb && sudo du -h --max-depth=1 /mnt/data2tb 2>/dev/null | sort -hr
```

Interactive space browser (Highly recommended):

```bash
sudo apt install ncdu -y
sudo ncdu /path/to/search
```
## 7. Safely Remove Disk

To avoid data corruption (especially with Bitcoin databases), follow this sequence:

1. **Stop all containers** using the disk:

```bash
sudo docker compose -f ./docker-compose.yml down
```

2. **Unmount** the disk:
```bash
sudo umount /mnt/data1tb
```

3. **Check** if it's gone:

```bash
df -h | grep sda1
```

## 8. System & User Space Cleanup

Commands to free up space from package managers, caches, and heavy application data.

### 8.1 Package Managers & Caches
```bash
# Clean PNPM global store
pnpm store prune

# Remove unused Flatpak runtimes/apps
flatpak uninstall --unused

# Clean APT package cache
sudo apt clean
```

### 8.2 Application Specific Data
```bash
# Clear Raspberry Pi Imager download cache
rm -rf ~/.var/app/org.raspberrypi.rpi-imager/cache/Raspberry\ Pi/Imager/lastdownload.cache

# Reset Waydroid (WARNING: This will delete the Android system/data images)
sudo waydroid container stop
waydroid session stop
sudo rm -rf /var/lib/waydroid/images/*.img
# Note: You will need to run 'sudo waydroid init' to use it again.

# Clear Windsurf (Codeium) embeddings database
rm -rf ~/.codeium/windsurf/database/
```

---

> [!TIP]
> Run `docker ps` before pruning to ensure all your important services (Jellyfin, qBittorrent, etc.) are running so their images or internal volumes aren't deleted!
