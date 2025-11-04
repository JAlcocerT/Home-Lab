---
tags: ["Monitoring"]
source_code: https://github.com/henrygd/beszel
---

# Beszel - Docker Container Monitoring

[Beszel](https://github.com/henrygd/beszel) is a self-hosted monitoring solution for Docker containers, providing an interface to monitor your Docker environment.

## Features
- Real-time container monitoring
- Resource usage statistics (CPU, memory, network, disk)
- Container logs viewer
- Multi-host monitoring support
- Lightweight and easy to deploy

## Prerequisites
- Docker
- Docker Compose
- Port 8090 available for the web interface

## Quick Start

1. **Create the data directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/beszel/beszel_data
   ```

2. **Start Beszel**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/beszel
   docker-compose up -d
   ```

3. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:8090`
   - The default credentials are:
     - Username: `admin`
     - Password: `admin`

4. **Set up the agent**:
   - Log in to the Beszel web interface
   - Go to "Settings" > "Agents"
   - Click "Add System"
   - Copy the provided `docker-compose` configuration for the agent
   - Update the `KEY` in your `docker-compose.yml` with the one from the web interface
   - Restart the services:
     ```bash
     docker-compose down
     docker-compose up -d
     ```

## Configuration

### Environment Variables

#### Beszel Service
- No additional environment variables needed for basic setup

#### Beszel Agent
- `PORT`: Port for the agent to listen on (default: 45876)
- `KEY`: Authentication key (get this from the web UI)

### Ports
- `8090:8090` - Web interface
- `45876` - Agent communication port (host network mode)

### Volumes
- `./beszel_data:/beszel_data` - Persistent storage for Beszel data
- `/var/run/docker.sock:/var/run/docker.sock:ro` - Read-only access to Docker daemon

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/beszel
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup Beszel data
tar -czvf beszel_backup_$(date +%Y%m%d).tar.gz ./beszel_data
```

### Restore
```bash
# Stop Beszel
docker-compose down

# Restore from backup
tar -xzvf beszel_backup_YYYYMMDD.tar.gz -C ./

# Start Beszel again
docker-compose up -d
```

## Security

### Important Security Notes
- Change the default admin password after first login
- The agent requires access to the Docker socket, which provides root-level access to the host
- Consider using a reverse proxy with HTTPS for remote access
- The agent runs in host network mode for better network visibility

### Recommended Security Practices
1. Set up a reverse proxy (Nginx, Caddy, Traefik) with HTTPS
2. Use a firewall to restrict access to port 8090
3. Regularly update to the latest version
4. Monitor the service for unusual activity

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f beszel`
- Ensure port 8090 is open in your firewall

#### Agent not connecting
- Check agent logs: `docker-compose logs -f beszel-agent`
- Verify the `KEY` in the agent configuration matches the one in the web UI
- Ensure the agent has network access to the Beszel service

#### Permission Issues
If you encounter permission issues with the Docker socket:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Integration

Beszel can be integrated with:
- Reverse proxies for HTTPS
- Monitoring and alerting systems
- Log management solutions

## License
Beszel is open source and licensed under the [MIT License](https://github.com/henrygd/beszel/blob/main/LICENSE).

## References
- [GitHub Repository](https://github.com/henrygd/beszel)
- [Docker Hub](https://hub.docker.com/r/henrygd/beszel)
