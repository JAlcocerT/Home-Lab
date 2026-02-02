---
source_code: https://github.com/Prowlarr/Prowlarr
tags: ["Torrent","Usenet","Indexer Manager"]
---


#https://docs.linuxserver.io/images/docker-prowlarr/
#https://wiki.servarr.com/                                    # ---> SEEDBOX
#https://docs.linuxserver.io/images/docker-prowlarr/#usage


---

# Prowlarr - Indexer Manager

[Prowlarr](https://github.com/Prowlarr/Prowlarr) is an indexer manager/proxy built on the popular arr .net/reactjs base stack to integrate with your various PVR apps. Prowlarr supports management of both Torrent Trackers and Usenet Indexers. 

It integrates seamlessly with various *Arr applications (Radarr, Sonarr, etc.) and can be used to manage all your indexers in one place.

  # flaresolverr:
  #   image: ghcr.io/flaresolverr/flaresolverr:latest
  #   container_name: flaresolverr
  #   environment:
  #     - LOG_LEVEL=info
  #     - TZ=Europe/Madrid
  #   ports:
  #     - "8191:8191"
  #   restart: unless-stopped

## Features

- Manage all your indexers in one place
- Sync with multiple *Arr applications
- Automatic indexer search
- Supports both Torrent and Usenet indexers
- Built-in proxy support

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Create the necessary directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/prowlarr/config
   ```

2. **Set proper permissions** (adjust UID/GID if needed):
   ```bash
   sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/prowlarr/config
   ```

3. **Start Prowlarr**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/prowlarr
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:9696`

## Configuration

### Environment Variables
- `PUID=1000` - User ID for the container user
- `PGID=1000` - Group ID for the container user
- `TZ=Europe/Madrid` - Timezone (change to your local timezone)

### Volumes
- `./config` - Configuration files and Prowlarr data
- `/etc/localtime:ro` - Synchronizes the container time with the host system

### Ports
- `9696` - Web UI port (change the first number if you need to use a different host port)

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/prowlarr
docker-compose pull
docker-compose up -d
```

## Deployment

```sh
# Pull latest changes
git pull

# Deploy Prowlarr from the main stack
sudo docker compose -f ./z-homelab-setup/evolution/2601_docker-compose.yml up -d prowlarr

# Verify status
docker ps -a | grep -i prowlarr
```

## Setup Instructions

1. Access the web UI at `http://<your-ip>:9696`.
2. Go to **Settings > Download Clients**.
3. Add **qBittorrent** using Host: `qbittorrent`.
```

## Backup and Restore

### Backup
```bash
# Backup Prowlarr configuration
tar -czvf prowlarr_backup_$(date +%Y%m%d).tar.gz /home/jalcocert/Desktop/IT/Home-Lab/prowlarr/config
```

### Restore
```bash
# Stop Prowlarr
docker-compose down

# Restore from backup
tar -xzvf prowlarr_backup_YYYYMMDD.tar.gz -C ./

# Start Prowlarr again
docker-compose up -d
```

## Integration with *Arr Apps

Prowlarr can sync with various *Arr applications:
1. Go to Settings > Apps in Prowlarr
2. Add your *Arr applications (Radarr, Sonarr, etc.)
3. Configure sync settings as needed

## Troubleshooting

### View Logs
```bash
docker-compose logs -f
```

### Reset Configuration
1. Stop the container:
   ```bash
   docker-compose down
   ```
2. Remove the configuration directory:
   ```bash
   rm -rf ./config/*
   ```
3. Start Prowlarr again:
   ```bash
   docker-compose up -d
   ```

## Security
- Change the default port if exposed to the internet
- Consider using a reverse proxy with HTTPS
- Keep the application updated

## License
Prowlarr is open source and licensed under the [GPL-3.0 License](https://github.com/Prowlarr/Prowlarr/blob/develop/LICENSE).

## References
- [GitHub Repository](https://github.com/Prowlarr/Prowlarr)
- [Official Wiki](https://wiki.servarr.com/prowlarr/)
- [Docker Hub](https://hub.docker.com/r/linuxserver/prowlarr)
