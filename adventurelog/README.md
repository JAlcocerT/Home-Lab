---
source_code: https://github.com/seanmorley15/AdventureLog
post: 
tags: "trip"
---

# AdventureLog - Self-Hosted Adventure Logging Platform

[AdventureLog](https://adventurelog.app/) is a self-hosted platform for logging and sharing your outdoor adventures, trips, and experiences.

## Features
- Track and share your adventures
- Photo galleries for your trips
- Route mapping
- Trip statistics
- Privacy-focused and self-hosted

## Prerequisites
- Docker
- Docker Compose
- Cloudflare Tunnel (optional, for external access)

## Quick Start

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/yourusername/your-repo.git
   cd adventurelog
   ```

2. **Edit the configuration**:
   - Open `docker-compose.yml`
   - Update all placeholders (marked with `# Change this!`)
   - Set your domain or IP in `ORIGIN`, `PUBLIC_URL`, `CSRF_TRUSTED_ORIGINS`, and `FRONTEND_URL`
   - Change all default passwords and secrets

3. **Create the Cloudflare Tunnel network** (if using Cloudflare Tunnels):
   ```bash
   docker network create cloudflared_tunnel
   ```

4. **Start AdventureLog**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/adventurelog
   docker-compose up -d
   ```

5. **Access the Web UI**:
   - Frontend: `http://your-server-ip:8015`
   - Backend: `http://your-server-ip:8016`
   - Admin user: Use the credentials you set in the environment variables

## Configuration

### Environment Variables

#### Frontend (web)
- `PUBLIC_SERVER_URL`: URL of the backend server (usually `http://server:8000`)
- `ORIGIN`: Public URL of your frontend (e.g., `https://adventure.yourdomain.com`)
- `BODY_SIZE_LIMIT`: Maximum request body size (default: `Infinity`)
- `PUBLIC_UMAMI_SRC`: (Optional) URL to your Umami analytics script
- `PUBLIC_UMAMI_WEBSITE_ID`: (Optional) Your Umami website ID

#### Backend (server)
- Database settings (match these with the db service)
- `SECRET_KEY`: A secure secret key for Django
- `DJANGO_ADMIN_*`: Admin user credentials
- `PUBLIC_URL`: Public URL of your backend
- `CSRF_TRUSTED_ORIGINS`: List of allowed origins for CSRF protection
- `FRONTEND_URL`: Public URL of your frontend
- `DISABLE_REGISTRATION`: Set to `True` to disable user registration

### Ports
- `8015:3000` - Frontend web interface
- `8016:80` - Backend API

### Volumes
- `postgres_data` - Database files
- `adventurelog_media` - Uploaded media files

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/adventurelog
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup database
docker exec -t adventurelog-db pg_dump -U adventure database > adventurelog_db_backup_$(date +%Y%m%d).sql

# Backup media files
tar -czvf adventurelog_media_backup_$(date +%Y%m%d).tar.gz $(docker volume inspect -f '{{ .Mountpoint }}' adventurelog_adventurelog_media)
```

### Restore
```bash
# Stop AdventureLog
docker-compose down

# Restore database
cat adventurelog_db_backup_YYYYMMDD.sql | docker exec -i adventurelog-db psql -U adventure database

# Restore media files
tar -xzvf adventurelog_media_backup_YYYYMMDD.tar.gz -C $(docker volume inspect -f '{{ .Mountpoint }}' adventurelog_adventurelog_media)

# Start AdventureLog again
docker-compose up -d
```

## Security

### Important Security Notes
- Change all default passwords and secrets
- Use HTTPS in production
- Keep the software updated
- Consider using a VPN or Cloudflare Tunnel for remote access

### Recommended Security Practices
1. Set up a reverse proxy with HTTPS
2. Enable the built-in firewall on your server
3. Regularly back up your data
4. Monitor logs for suspicious activity

## Troubleshooting

### Common Issues

#### Can't access the web interface
- Verify all containers are running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure ports 8015 and 8016 are open in your firewall

#### Database connection issues
- Verify the database container is running
- Check the logs: `docker-compose logs -f db`
- Ensure the database credentials match in both the db and server services

#### Image upload issues
- Verify the `adventurelog_media` volume has the correct permissions
- Check the server logs for specific error messages
- Ensure `PUBLIC_URL` is correctly set

## Integration

AdventureLog can be integrated with:
- Cloudflare Tunnels for secure remote access
- Umami Analytics for usage statistics
- Reverse proxies like Nginx or Caddy

## License
AdventureLog is open source and licensed under the [MIT License](https://github.com/seanmorley15/AdventureLog/blob/main/LICENSE).

## References
- [GitHub Repository](https://github.com/seanmorley15/AdventureLog)
- [Official Documentation](https://adventurelog.app/)
- [Docker Hub](https://github.com/seanmorley15/AdventureLog/pkgs/container/adventurelog-frontend)
