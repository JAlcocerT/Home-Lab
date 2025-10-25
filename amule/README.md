---
source_code: https://github.com/ngosang/docker-amule
tags: ["torrent","p2p","media"]
---

---

# aMule - eDonkey/Kad Network Client

aMule is a free peer-to-peer file sharing application that works with the eDonkey Network and the Kad Network, offering similar functionality to eMule and adding peer-to-peer support through the Kademlia network.

## Features
- Web interface for remote management
- Support for eD2k and Kademlia networks
- Cross-platform compatibility
- Multiple download queues
- File checksums and corruption recovery
- IP filtering support

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Edit the configuration**:
   - Open `docker-compose.yml`
   - Change `GUI_PWD` and `WEBUI_PWD` to secure passwords
   - Adjust other settings as needed

2. **Set proper permissions**:
   ```bash
   sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/amule/{config,incoming,temp}
   ```

3. **Start aMule**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/amule
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:4711`
   - Username: `admin`
   - Password: (the one you set in WEBUI_PWD)

## Configuration

### Environment Variables
- `PUID=1000` - User ID for the container user
- `PGID=1000` - Group ID for the container user
- `TZ=Europe/Madrid` - Timezone
- `GUI_PWD` - Password for the GUI (change this!)
- `WEBUI_PWD` - Password for the Web UI (change this!)
- `MOD_AUTO_RESTART_ENABLED` - Enable automatic restart
- `MOD_AUTO_RESTART_CRON` - Cron schedule for restarts (default: daily at 6 AM)
- `MOD_AUTO_SHARE_ENABLED` - Enable auto-sharing of directories
- `MOD_AUTO_SHARE_DIRECTORIES` - Directories to share (semicolon-separated)
- `MOD_FIX_KAD_GRAPH_ENABLED` - Enable KAD graph optimization
- `MOD_FIX_KAD_BOOTSTRAP_ENABLED` - Enable KAD bootstrap optimization

### Volumes
- `./config` - aMule configuration files
- `./incoming` - Completed downloads
- `./temp` - Temporary download files

### Ports
- `4711` - Web UI
- `4712` - Remote GUI, webserver, cmd
- `4662` - eD2K TCP
- `4665/udp` - eD2K global search UDP
- `4672/udp` - eD2K UDP

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/amule
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup configuration and incomplete downloads
tar -czvf amule_backup_$(date +%Y%m%d).tar.gz ./config ./temp

# Backup completed downloads (if needed)
tar -czvf amule_downloads_$(date +%Y%m%d).tar.gz ./incoming
```

### Restore
```bash
# Stop aMule
docker-compose down

# Restore from backup
tar -xzvf amule_backup_YYYYMMDD.tar.gz -C ./
tar -xzvf amule_downloads_YYYYMMDD.tar.gz -C ./

# Start aMule again
docker-compose up -d
```

## Security

### Important Security Notes
- **Always** change the default passwords in the `docker-compose.yml` file
- Consider using a reverse proxy with HTTPS for the Web UI
- Only expose the necessary ports to the internet
- Regularly update to the latest version

### Recommended Security Practices
1. Use strong, unique passwords for both GUI and Web UI
2. Configure IP filtering to block known bad peers
3. Consider running behind a VPN for additional privacy
4. Regularly back up your configuration

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure port 4711 is open in your firewall

#### Permission Issues
If you encounter permission issues with the volumes:
```bash
sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/amule/{config,incoming,temp}
```

#### Port Conflicts
If you get port binding errors, ensure no other service is using the required ports (4711, 4712, 4662, 4665/udp, 4672/udp).

## Integration

aMule can be integrated with various tools:
- **Monitoring**: Use the Web UI or remote GUI to monitor downloads
- **Automation**: Use the command-line interface for automation
- **VPN**: Consider running the container with a VPN for additional privacy

## License
aMule is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation.

## References
- [GitHub Repository](https://github.com/ngosang/docker-amule)
- [Official Website](https://www.amule.org/)
- [Documentation](https://wiki.amule.org/)
- [Docker Hub](https://hub.docker.com/r/ngosang/amule/)
