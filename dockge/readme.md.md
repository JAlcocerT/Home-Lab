---
post: https://fossengineer.com/selfhosting-dockge/
source_code: https://github.com/louislam/dockge
official_site: https://dockge.khuedoan.com/
---

# Dockge - Docker Compose Manager

Dockge is a simple, lightweight, and beautiful self-hosted Docker Compose.yaml stack manager with a web interface.

## Features
- Manage Docker Compose stacks with a web interface
- Real-time container logs and stats
- One-click start/stop/restart/update containers
- Built-in terminal access
- Lightweight and fast

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Start Dockge**:
   ```bash
   docker-compose up -d
   ```

2. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:5001`
   - The default username is `admin` and the password is `dockge`

## Configuration

### Volumes
- `./dockge` - Stores Dockge's configuration and data
- `/docker` - Optional: Mount your existing docker-compose files directory

### Environment Variables
- `DOCKGE_STACKS_DIR`: Directory where your docker-compose files are stored (default: `/docker`)
- `TZ`: Timezone (default: `Europe/Madrid`)

### Ports
- `5001`: Web UI port (change if needed in `docker-compose.yml`)

## Usage

### Adding Stacks
1. Click "Add Stack" in the web interface
2. Enter a stack name and paste your `docker-compose.yml` content
3. Click "Deploy"

### Managing Stacks
- **Start/Stop/Restart**: Use the buttons in the web interface
- **Update**: Pull the latest images and recreate containers
- **Terminal**: Access container shell directly from the web interface
- **Logs**: View real-time container logs

## Backup and Restore

### Backup
```bash
# Backup Dockge data
tar -czvf dockge_backup_$(date +%Y%m%d).tar.gz ./dockge
```

### Restore
```bash
# Stop Dockge
docker-compose down

# Restore from backup
tar -xzvf dockge_backup_YYYYMMDD.tar.gz -C ./

# Start Dockge again
docker-compose up -d
```

## Security
- Change the default password after first login
- Expose the web interface only over HTTPS in production
- Use a reverse proxy (like Nginx) with SSL/TLS

## Troubleshooting

### View Logs
```bash
docker-compose logs -f
```

### Reset Admin Password
1. Stop the container:
   ```bash
   docker-compose down
   ```
2. Remove the password file:
   ```bash
   rm ./dockge/users/admin/password
   ```
3. Start Dockge again:
   ```bash
   docker-compose up -d
   ```
4. The default password will be reset to `dockge`

## Updating
```bash
# Pull the latest image
docker-compose pull

# Recreate the container
docker-compose up -d --force-recreate
```