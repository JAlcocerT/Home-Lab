# FileBrowser - Web File Manager

[FileBrowser](https://filebrowser.org/) provides a file managing interface within a specified directory and can be used to upload, delete, preview, rename and edit your files. It allows the creation of multiple users and each user can have its own directory.

## Features
- Web-based file management
- User authentication
- File uploads and downloads
- File previews
- Mobile-friendly interface
- Multiple user support

## Prerequisites
- Docker
- Docker Compose
- Cloudflare Tunnel network (for external access)

## Quick Start

1. **Create the config directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/filebrowser/config
   ```

2. **Set proper permissions**:
   ```bash
   sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/filebrowser/config
   ```

3. **Start FileBrowser**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/filebrowser
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:8082`
   - Default credentials: `admin` / `admin`

## Configuration

### Volumes
- `./config` - FileBrowser configuration and database
- `/home/jalcocert/EntreAgujayPunto:/srv` - The directory you want to manage (adjust as needed)

### Ports
- `8082:80` - Web UI port (change the first number if needed)

### Networks
- `cloudflared_tunnel` - External network for Cloudflare Tunnel access

## First Run Setup

1. Access the web interface
2. Log in with the default credentials
3. Change the admin password immediately
4. Configure additional settings as needed

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/filebrowser
docker-compose pull
docker-compose up -d
```

## Backup and Restore

### Backup
```bash
# Backup configuration
tar -czvf filebrowser_backup_$(date +%Y%m%d).tar.gz ./config

# Backup your files (adjust the path as needed)
tar -czvf files_backup_$(date +%Y%m%d).tar.gz /home/jalcocert/EntreAgujayPunto
```

### Restore
```bash
# Stop FileBrowser
docker-compose down

# Restore configuration
tar -xzvf filebrowser_backup_YYYYMMDD.tar.gz -C ./

# Restore files (if needed)
tar -xzvf files_backup_YYYYMMDD.tar.gz -C /home/jalcocert/

# Start FileBrowser again
docker-compose up -d
```

## Security

### Important Security Notes
- **Change the default password** after first login
- Use HTTPS in production (consider using a reverse proxy)
- Limit access to the FileBrowser interface
- Regularly update to the latest version

### Recommended Security Practices
1. Use strong, unique passwords
2. Enable authentication
3. Set up proper file permissions
4. Consider using a VPN or Cloudflare Tunnel for remote access

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure port 8082 is open in your firewall

#### Permission Issues
If you encounter permission issues with the volumes:
```bash
# For the config directory
sudo chown -R 1000:1000 /home/jalcocert/Desktop/IT/Home-Lab/filebrowser/config

# For the shared directory (adjust permissions as needed)
sudo chown -R 1000:1000 /home/jalcocert/EntreAgujayPunto
```

## Integration

FileBrowser can be integrated with:
- Cloudflare Tunnels for secure remote access
- Reverse proxies like Nginx or Caddy
- Monitoring solutions

## License
FileBrowser is open source and licensed under the [Apache License 2.0](https://github.com/filebrowser/filebrowser/blob/master/LICENSE).

## References
- [GitHub Repository](https://github.com/filebrowser/filebrowser)
- [Documentation](https://filebrowser.org/)
- [Docker Hub](https://hub.docker.com/r/filebrowser/filebrowser/)
