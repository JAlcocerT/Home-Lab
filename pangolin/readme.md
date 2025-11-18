---
source_code: https://github.com/fosrl/pangolin
post: https://fossengineer.com/selfhosting-pangolin-cloudflared-tunnel-alternative/
---

See also 

1. https://github.com/localtunnel/server - *localtunnel exposes your localhost to the world for easy testing and sharing! No need to mess with DNS or deploy just to have others test out your changes.*


# Pangolin - Self-Hosted Deployment

[Pangolin](https://github.com/fosrl/pangolin) is a self-hosted web application for managing and monitoring your services.

## Features
- Simple web interface
- Service monitoring
- Easy deployment with Docker
- Lightweight and fast

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/yourusername/your-repo.git
   cd pangolin
   ```

2. **Create a `.env` file** (optional):
   ```bash
   cp .env.example .env
   # Edit the .env file with your configuration
   ```

3. **Start Pangolin**:
   ```bash
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:3000`

## Configuration

### Environment Variables

Create a `.env` file in the project root with your configuration:

```env
# Application
NODE_ENV=production
PORT=3000

# Database (if using PostgreSQL)
# DATABASE_URL=postgres://user:password@postgres:5432/pangolin
```

### Volumes
- `./data` - Application data directory

### Ports
- `3000` - Web UI port (change if needed in `docker-compose.yml`)

## Using PostgreSQL (Optional)

1. Uncomment the PostgreSQL service in `docker-compose.yml`
2. Update the database configuration in your `.env` file
3. Restart the services:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Updating

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup application data
tar -czvf pangolin_backup_$(date +%Y%m%d).tar.gz ./data

# If using PostgreSQL
docker exec pangolin-db pg_dump -U pangolin pangolin > pangolin_db_backup_$(date +%Y%m%d).sql
```

### Restore
```bash
# Stop the services
docker-compose down

# Restore application data
tar -xzvf pangolin_backup_YYYYMMDD.tar.gz -C ./

# If using PostgreSQL
cat pangolin_db_backup_YYYYMMDD.sql | docker exec -i pangolin-db psql -U pangolin

# Start the services
docker-compose up -d
```

## Troubleshooting

### View Logs
```bash
docker-compose logs -f
```

### Reset Application
1. Stop and remove containers:
   ```bash
   docker-compose down -v
   ```
2. Remove the data directory:
   ```bash
   rm -rf ./data
   ```
3. Start fresh:
   ```bash
   docker-compose up -d
   ```

## Security
- Change default credentials if any
- Use a reverse proxy with HTTPS in production
- Regularly update to the latest version

## License
Pangolin is open source. See the [GitHub repository](https://github.com/fosrl/pangolin) for license information.

## References
- [GitHub Repository](https://github.com/fosrl/pangolin)
- [Documentation](https://github.com/fosrl/pangolin#readme)
