---
source_code: https://github.com/gotify/server
official_docs: https://gotify.net/docs/
tags: "notifications"
---

# Gotify - Self-Hosted Push Notifications

[Gotify](https://gotify.net/) is a simple server for sending and receiving messages in real-time per WebSocket, with a sleek web UI and Android app.

## Features
- Simple REST-API for sending and receiving messages
- WebSocket and HTTP long-polling for real-time updates
- Small, fast, and self-contained
- Web interface to manage users, applications, and messages
- Cross-platform (Android app available)

## Prerequisites
- Docker
- Docker Compose
- Port 6886 available (or change the port in the compose file)

## Quick Start

1. **Edit the configuration**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/gotify
   nano docker-compose.yml
   ```
   - Change all passwords (marked with `change_this`)
   - Update the timezone if needed
   - Change the default admin username/password if desired

2. **Start Gotify**:
   ```bash
   docker-compose up -d
   ```

3. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:6886`
   - Log in with the default credentials (unless you changed them):
     - Username: `admin`
     - Password: `change_this_too`

## Configuration

### Environment Variables

#### Gotify Service
- `GOTIFY_DATABASE_DIALECT`: Database type (postgres)
- `GOTIFY_DATABASE_CONNECTION`: Database connection string
- `GOTIFY_DEFAULTUSER_NAME`: Default admin username
- `GOTIFY_DEFAULTUSER_PASS`: Default admin password
- `GOTIFY_REGISTRATION`: Allow new user registration (false = admin must create users)
- `TZ`: Timezone (e.g., `Europe/Madrid`)

#### PostgreSQL Service
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password (must match the one in the connection string)

### Ports
- `6886:80` - Web UI and API (change the first number if needed)

### Volumes
- `gotify_data` - Gotify application data
- `postgres_data` - PostgreSQL database files

## Updating

To update to the latest version:

```bash
cd /home/jalcocert/Desktop/IT/Home-Lab/gotify
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup Gotify data
docker run --rm -v gotify_gotify_data:/source -v $(pwd):/backup alpine tar czf /backup/gotify_data_backup_$(date +%Y%m%d).tar.gz -C /source .

# Backup PostgreSQL data
docker exec gotify_db pg_dump -U gotify gotify > gotify_db_backup_$(date +%Y%m%d).sql
```

### Restore
```bash
# Stop Gotify
docker-compose down

# Restore Gotify data
docker run --rm -v gotify_gotify_data:/target -v $(pwd):/backup alpine sh -c "cd /target && tar xzf /backup/gotify_data_backup_YYYYMMDD.tar.gz"

# Restore PostgreSQL data
cat gotify_db_backup_YYYYMMDD.sql | docker exec -i gotify_db psql -U gotify gotify

# Start Gotify again
docker-compose up -d
```

## Security

### Important Security Notes
- Change all default passwords before exposing to the internet
- Consider using a reverse proxy with HTTPS
- Keep the software updated
- Use strong passwords for all accounts

### Recommended Security Practices
1. Set up a reverse proxy (Nginx, Caddy, Traefik) with HTTPS
2. Use a firewall to restrict access to the service
3. Regularly back up your data
4. Monitor logs for suspicious activity

## Troubleshooting

### Common Issues

#### Can't access Web UI
- Verify the container is running: `docker ps`
- Check logs: `docker-compose logs -f`
- Ensure port 6886 is open in your firewall

#### Database Connection Issues
- Check if the PostgreSQL container is running: `docker ps`
- Verify the database credentials in the connection string
- Check PostgreSQL logs: `docker-compose logs -f postgres`

## Integration

Gotify can be integrated with:
- [Gotify Android App](https://github.com/gotify/android)
- [Gotify CLI](https://github.com/gotify/cli)
- [Gotify Desktop](https://github.com/Deseteral/gotify-tray)
- Various third-party clients and libraries

## License
Gotify is open source and licensed under the [MIT License](https://github.com/gotify/server/blob/v2/LICENSE).

## References
- [GitHub Repository](https://github.com/gotify/server)
- [Official Documentation](https://gotify.net/docs/)
- [Docker Hub](https://hub.docker.com/r/gotify/server/)
