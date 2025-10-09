---
source_code: https://github.com/orb-community/orb
---

# Orb - Network Sensor

[Orb](https://orb.community/) is an open-source, distributed network monitoring and analytics platform that provides real-time visibility into your network traffic.

## Features
- Real-time network monitoring
- Distributed architecture
- Web-based dashboard
- Network traffic analysis
- Resource usage monitoring

## Prerequisites
- Docker
- Docker Compose
- Ports 7443 and 5353 available

## Quick Start

1. **Start Orb**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/orb
   docker-compose up -d
   ```

2. **Access the Web UI**:
   - Open your browser and go to: `https://your-server-ip:7443`
   - The default credentials are usually `admin` / `orb` (check Orb documentation for the latest)

## Configuration

### Ports
- `7443` - Web UI (HTTPS)
- `5353` - Network discovery and communication

### Volumes
- `orb-data` - Persistent storage for Orb configuration and data

### Environment Variables
None required by default, but can be added to the `environment:` section if needed.

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/orb
docker-compose pull
docker-compose up -d
```

## Automatic Updates (Optional)

To enable automatic updates using Watchtower:

1. Uncomment the Watchtower service in `docker-compose.yml`
2. Uncomment the labels in the orb-docker service
3. Restart the services:
   ```bash
   docker-compose up -d
   ```

## Backup and Restore

### Backup
```bash
# Backup Orb configuration
docker run --rm -v orb_orb-data:/source -v $(pwd):/backup alpine tar czf /backup/orb_backup_$(date +%Y%m%d).tar.gz -C /source .
```

### Restore
```bash
# Stop Orb
docker-compose down

# Restore from backup
docker run --rm -v orb_orb-data:/target -v $(pwd):/backup alpine sh -c "cd /target && tar xzf /backup/orb_backup_YYYYMMDD.tar.gz"

# Start Orb again
docker-compose up -d
```

## Security

### Important Security Notes
- Change the default credentials after first login
- Consider using a reverse proxy with HTTPS
- Limit access to the Web UI using a firewall
- Keep the software updated

### Recommended Security Practices
1. Use strong, unique passwords
2. Configure network access controls
3. Monitor the service for unusual activity
4. Regularly back up your configuration

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure ports 7443 and 5353 are open in your firewall

#### Permission Issues
If you encounter permission issues with the volume:
```bash
docker run --rm -it -v orb_orb-data:/data alpine chown -R 1000:1000 /data
```

## Integration

Orb can be integrated with various monitoring and alerting systems. Check the official documentation for more details.

## License
Orb is open source and licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## References
- [Official Documentation](https://docs.orb.community/)
- [GitHub Repository](https://github.com/orb-community/orb)
- [Docker Hub](https://hub.docker.com/r/orbcommunity/orb)
