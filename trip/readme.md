---
source_code: https://github.com/itskovacs/trip
docs: https://github.com/itskovacs/trip/tree/main/docs
tags: ["trip"]
---

# Trip - Personal Dashboard

 🗺️ Minimalist POI Map Tracker and Trip Planner 

## Features

- Customizable dashboard with widgets
- Bookmark management
- Note-taking capabilities
- Task tracking
- Weather information
- RSS feed reader
- And more...

## Prerequisites

- Docker and Docker Compose installed
- Port 3000 available on your host machine

## Quick Start

1. Create the `docker-compose.yml` file.

2. Create a data directory for persistent storage:
   
```bash
mkdir -p data
```

3. Start the service:

```bash
docker-compose up -d
```

## Access

Access your Trip dashboard at: `http://your-server-ip:3000`

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Node.js environment |
| `PORT` | `3000` | Port the application runs on (container port) |
| `TZ` | `UTC` | Timezone for the application |
| `AUTH_ENABLED` | `false` | Enable basic authentication |
| `AUTH_USERNAME` | - | Username for authentication |
| `AUTH_PASSWORD` | - | Password for authentication |
| `DB_CLIENT` | `sqlite3` | Database client to use |
| `DB_FILENAME` | `/data/trip.db` | Path to SQLite database file |

### Persistent Storage

The application stores its data in the following locations:

- `/data` - Contains the database and any uploaded files

## Updating

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup

To back up your Trip data, simply back up the `./data` directory.

## Security Considerations

1. **Always** set up authentication when exposing the dashboard to the internet
2. Consider setting up a reverse proxy with HTTPS (e.g., Nginx, Traefik, Caddy)
3. Keep your Docker installation and the Trip image up to date

## Troubleshooting

### View logs

```bash
docker-compose logs -f
```

### Reset admin password

If you've enabled authentication and forgotten your password, you can reset it by:

1. Stopping the container
2. Deleting the database file (`rm data/trip.db`)
3. Restarting the container

## License

This project is open source and available under the [MIT License](https://github.com/itskovacs/trip/blob/main/LICENSE).
