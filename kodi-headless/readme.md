---
source_code: https://github.com/linuxserver/kodi-headless
tags: ["Music Server","Media Server"]
---

# Kodi Headless - Media Server

[Kodi](https://kodi.tv/) is a free and open-source media player software application developed by the XBMC Foundation. This is a headless version that runs without a graphical interface, perfect for server environments.

## Features
- Headless Kodi instance for server use
- Web interface for remote management
- Support for various add-ons and plugins
- Media library management
- Remote control via HTTP API

## Prerequisites
- Docker
- Docker Compose
- Ports 8066, 9098, and 9777/udp available

## Quick Start

1. **Create the config directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/kodi-headless/config
   ```

2. **Set proper permissions**:
   ```bash
   sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/kodi-headless/config
   ```
   
   > **Note**: Ensure the PUID and PGID in the docker-compose.yml match your host user/group IDs.

3. **Start Kodi Headless**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/kodi-headless
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:8066`
   - The default username is `kodi` and the password is `kodi`

## Configuration

### Environment Variables
- `PUID=1000` - User ID for the container user
- `PGID=1000` - Group ID for the container user
- `TZ=Europe/Madrid` - Timezone (change to your local timezone)

### Ports
- `8066:8080` - Web interface
- `9098:9090` - Event server port (for Kodi Remote apps)
- `9777:9777/udp` - Zeroconf/avahi service discovery

### Volumes
- `./config:/config/.kodi` - Kodi configuration and database
- (Optional) Add your media directories as needed

## Adding Media

To add media to your Kodi library:

1. Mount your media directories by uncommenting and updating the volumes section in `docker-compose.yml`:
   ```yaml
   volumes:
     - ./config:/config/.kodi
     - /path/to/your/movies:/movies
     - /path/to/your/tvshows:/tvshows
   ```

2. Restart the container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Add the media sources through the web interface or Kodi remote app.

## Remote Control

You can control Kodi using:
- Web interface: `http://your-server-ip:8066`
- Kodi Remote apps (use port 9098)
- HTTP API (JSON-RPC)

## Hardware Acceleration (Optional)

For better performance, you can enable hardware acceleration by uncommenting the relevant devices in the docker-compose.yml file.

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/kodi-headless
docker-compose pull
docker-compose up -d
```

## Backup and Restore

### Backup
```bash
# Backup Kodi configuration
tar -czvf kodi_config_backup_$(date +%Y%m%d).tar.gz ./config
```

### Restore
```bash
# Stop Kodi
docker-compose down

# Restore from backup
tar -xzvf kodi_config_backup_YYYYMMDD.tar.gz -C ./

# Start Kodi again
docker-compose up -d
```

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure ports 8066, 9098, and 9777/udp are open in your firewall

#### Permission Issues
If you encounter permission issues with the volumes:
```bash
sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/kodi-headless/config
```

#### Hardware Acceleration Issues
If using hardware acceleration, ensure:
1. The correct devices are mounted in the container
2. Your user has permission to access the GPU
3. The correct drivers are installed on the host

## Integration

Kodi can be integrated with:
- Media scrapers (The Movie Database, TVDB, etc.)
- Subtitles add-ons
- Streaming services
- Home automation systems

## License
Kodi is open source and licensed under the [GPL-2.0 License](https://github.com/xbmc/xbmc/blob/master/README.md).

## References
- [GitHub Repository](https://github.com/xbmc/xbmc)
- [Official Website](https://kodi.tv/)
- [Documentation](https://kodi.wiki/)
- [Docker Hub](https://hub.docker.com/r/linuxserver/kodi-headless/)
