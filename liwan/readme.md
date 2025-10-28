---
source_code: https://github.com/explodingcamera/liwan
official_docs: https://liwan.dev/ 
tag: "web-analytics"
---

Quickly get started with Liwan with a single, self-contained binary . **No database or complex setup required.**

The tracking script is a single line of code that works with any website and adds less than 1KB to your page size.


# Liwan - Self-Hosted Link Shortener

[Liwan](https://liwan.dev/) is a simple, fast, and self-hosted link shortener with a clean web interface and API.

## Features
- Simple and clean web interface
- RESTful API
- Custom short URLs
- Link analytics
- Self-hosted and privacy-focused

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Edit the configuration**:
   - Open `docker-compose.yml`
   - Update `LIWAN_BASE_URL` with your server's IP or domain
   - Choose your preferred port binding (local or network access)

2. **Start Liwan**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/liwan
   docker-compose up -d
   ```

3. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:9042`

## Configuration

### Environment Variables
- `LIWAN_BASE_URL` - The base URL of your Liwan instance (e.g., `http://your-domain.com` or `http://192.168.1.11`)

### Ports
- `9042:9042` - Web interface and API (exposed to the network)
- `127.0.0.1:9042:9042` - Alternative: Only accessible from localhost (more secure)

### Volumes
- `liwan-data` - Persistent storage for Liwan data

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/liwan
docker-compose pull
docker-compose up -d
```

## Backup and Restore

### Backup
```bash
# Backup Liwan data
docker run --rm -v liwan-data:/source -v $(pwd):/backup alpine tar czf /backup/liwan_backup_$(date +%Y%m%d).tar.gz -C /source .
```

### Restore
```bash
# Stop Liwan
docker-compose down

# Restore from backup
docker run --rm -v liwan-data:/target -v $(pwd):/backup alpine sh -c "cd /target && tar xzf /backup/liwan_backup_YYYYMMDD.tar.gz"

# Start Liwan again
docker-compose up -d
```

## Security

### Important Security Notes
- If exposing to the internet, consider using a reverse proxy with HTTPS
- For local use only, consider binding to 127.0.0.1 instead of all interfaces
- Keep the software updated

### Recommended Security Practices
1. Use a reverse proxy (like Nginx or Caddy) with HTTPS
2. Set up authentication if needed
3. Regularly back up your data
4. Monitor access logs

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure port 9042 is open in your firewall

#### Permission Issues
If you encounter permission issues with the volume:
```bash
docker run --rm -it -v liwan-data:/data alpine chown -R 1000:1000 /data
```

## Integration

Liwan provides a RESTful API that can be integrated with:
- Custom scripts
- Mobile apps
- Browser extensions
- Other services

## License
Liwan is open source and licensed under the [MIT License](https://github.com/explodingcamera/liwan/blob/main/LICENSE).

## References
- [GitHub Repository](https://github.com/explodingcamera/liwan)
- [Official Documentation](https://liwan.dev/)
- [Docker Hub](https://github.com/explodingcamera/liwan/pkgs/container/liwan)
