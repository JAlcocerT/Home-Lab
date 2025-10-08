---
post: 
source_code: https://github.com/metabase/metabase
official_docs: https://www.metabase.com/docs/latest/
---

# Metabase Deployment Options

This repository contains two different deployment configurations for Metabase:

1. **H2 (Embedded Database)** - Simple setup with built-in H2 database
2. **PostgreSQL** - Production-ready setup with PostgreSQL

## Prerequisites

- Docker
- Docker Compose

## H2 Configuration (Simple)

**Best for**: Testing, development, or small-scale personal use

### Quick Start

```bash
cd h2
docker-compose up -d
```

Access the web interface at: `http://localhost:3000`

### Features
- Single container setup
- Data persistence using Docker volumes
- Automatic restarts
- Health checks

## PostgreSQL Configuration (Production)

**Best for**: Production environments, teams, or larger deployments

### Quick Start

1. **Optional**: Edit the `.env` file to change default credentials
2. Start the services:
   ```bash
   cd postgres
   docker-compose up -d
   ```
3. Access the web interface at: `http://localhost:3000`

### Features
- Separate database and application containers
- Persistent storage for both Metabase and PostgreSQL
- Network isolation
- Health monitoring
- Automatic restarts

## Maintenance

### Backups

#### H2 Version
```bash
docker cp metabase-h2:/metabase-data/metabase.db ./metabase-backup-$(date +%Y%m%d).db
```

#### PostgreSQL Version
```bash
docker exec -t metabase-postgres pg_dump -U metabase metabase > metabase-backup-$(date +%Y%m%d).sql
```

### Upgrading
To upgrade to a newer version of Metabase:

1. Stop the containers:
   ```bash
   docker-compose down
   ```
2. Pull the latest image:
   ```bash
   docker-compose pull
   ```
3. Restart the services:
   ```bash
   docker-compose up -d
   ```

## Troubleshooting

### View Logs
```bash
docker-compose logs -f
```

### Reset Admin Password
```bash
docker exec -it metabase-h2 java -jar /metabase.jar reset-password <email>
```

## License
Metabase is open source and licensed under the [AGPL](https://www.gnu.org/licenses/agpl-3.0.en.html).

## References
- [Official Documentation](https://www.metabase.com/docs/latest/)
- [GitHub Repository](https://github.com/metabase/metabase)


---

H2 is a Java-based, open-source relational database management system (RDBMS) that can run in embedded or server mode. It's similar to SQLite but with some key differences:

### H2 Database Characteristics:
1. **In-Memory & Disk-Based**: Can run entirely in-memory or persist to disk
2. **SQL Compatibility**: Supports a large subset of the SQL standard
3. **Zero Configuration**: Works out of the box with minimal setup
4. **Pure Java**: Runs on any platform with Java
5. **Web Console**: Includes a built-in web interface

### H2 vs SQLite:
| Feature         | H2                          | SQLite                     |
|-----------------|----------------------------|---------------------------|
| **Language**    | Java                       | C                         |
| **Server Mode** | Yes (can act as a server)  | No (embedded only)        |
| **Concurrency** | Better for multiple users  | Better for single process |
| **Size**        | Larger footprint           | Very lightweight         |
| **Use Case**    | Java applications, testing | Mobile apps, local apps   |

### In the Context of Metabase:
- **H2 (Default)**: Great for testing and small-scale use
  - Simple setup (single container)
  - No separate database server needed
  - Good for development and evaluation
  - Not recommended for production

- **PostgreSQL**: Better for production
  - More robust
  - Better performance under load
  - Supports multiple concurrent users
  - More reliable data storage

The configuration you're looking at uses H2 with persistent storage (`MB_DB_FILE=/metabase-data/metabase.db`), which means your data will be saved in a Docker volume and persist between container restarts.