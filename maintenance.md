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

---

> [!TIP]
> Run `docker ps` before pruning to ensure all your important services (Jellyfin, qBittorrent, etc.) are running so their images or internal volumes aren't deleted!
