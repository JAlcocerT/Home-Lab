---
source_code: https://github.com/azukaar/Cosmos-Server
tags: "PaaS"
---

# Cosmos Server - Self-Hosted Cloud Platform

[Cosmos Server](https://cosmos-cloud.io/) is a self-hosted cloud platform that allows you to run your own cloud services with a focus on privacy and security.

## Features
- Web-based interface for managing services
- Docker container management
- File browser and manager
- App store for one-click installations
- User management and permissions
- Automatic HTTPS with Let's Encrypt

## Prerequisites
- Docker
- Docker Compose
- Ports 800 and 4433 available

## Quick Start

1. **Create the config directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/cosmos-server/config
   ```

2. **Set proper permissions**:
   ```bash
   sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/cosmos-server/config
   ```

3. **Start Cosmos Server**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/cosmos-server
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:800`
   - Follow the initial setup wizard

## Configuration

### Environment Variables
- `TZ` - Timezone (default: `Europe/Madrid`)
- `COSMOS_PASSWORD` - (Optional) Set an admin password during container startup
- `COSMOS_SECRET_KEY` - (Optional) Set a secret key for encryption

### Ports
- `800:80` - Web UI (HTTP)
- `4433:443` - Web UI (HTTPS)

### Volumes
- `/var/run/docker.sock` - Required for Docker management
- `/:/mnt/host` - Mounts the host filesystem
- `./config` - Persists configuration data

## Security Considerations

### Important Security Notes
1. **Privileged Mode**: This container runs in privileged mode, which gives it extensive access to your host system. Only use this in trusted environments.
2. **Host Filesystem Access**: The container has full read/write access to your host filesystem via `/mnt/host`.
3. **Docker Socket Access**: The container can manage all Docker containers on your host.
4. **Default Credentials**: Change the default admin password during initial setup.

### Recommended Security Practices
1. **Network Isolation**:
   - Place Cosmos Server behind a reverse proxy (like Nginx or Traefik)
   - Use a VPN for remote access instead of exposing the web interface directly

2. **Access Control**:
   - Use strong, unique passwords
   - Enable two-factor authentication if available
   - Regularly review user permissions

3. **Updates**:
   - Regularly update to the latest version
   - Subscribe to security announcements

4. **Backup**:
   - Regularly back up the `./config` directory
   - Consider using volume backups for important data

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/cosmos-server
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup configuration
tar -czvf cosmos_backup_$(date +%Y%m%d).tar.gz ./config
```

### Restore
```bash
# Stop Cosmos Server
docker-compose down

# Restore from backup
tar -xzvf cosmos_backup_YYYYMMDD.tar.gz -C ./

# Start Cosmos Server again
docker-compose up -d
```

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure ports 800 and 4433 are open in your firewall

#### Permission Issues
If you encounter permission issues with volumes:
```bash
sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/cosmos-server/config
```

#### Docker Socket Access
If you see Docker-related errors:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Integration

Cosmos Server can be integrated with:
- Reverse proxies (Nginx, Traefik, Caddy)
- Monitoring solutions
- Backup solutions

## License
Cosmos Server is open source and licensed under the [AGPL-3.0 License](https://github.com/azukaar/Cosmos-Server/blob/master/LICENSE).

## References
- [GitHub Repository](https://github.com/azukaar/Cosmos-Server)
- [Official Website](https://cosmos-cloud.io/)
- [Documentation](https://docs.cosmos-cloud.io/)
