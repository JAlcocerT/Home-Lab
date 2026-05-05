---
source_code: https://github.com/davidmonterocrespo24/velxio
tags: ["IoT"]
moto:  
yt_video: https://youtu.be/H5Q6fQyPptE
---


# Velxio Deployment Guide

Real-world deployment experience from running Velxio locally via Docker Compose.

## Quick Start (TL;DR)

```bash
cd /path/to/velxio
cat > backend/.env << 'EOF'
SECRET_KEY=dev-key-change-in-production-this-is-only-for-testing
DATABASE_URL=sqlite+aiosqlite:////app/data/velxio.db
DATA_DIR=/app/data
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:3080/api/auth/google/callback
FRONTEND_URL=http://localhost:3080
COOKIE_SECURE=false
EOF

docker compose up --build
# Access at http://localhost:3080
```

---

## Prerequisites

- **Docker** (20.10+) and **Docker Compose** (2.0+)
- **Disk space**: 
  - Image build: ~2.5 GB
  - Running: ~225 MB RAM (idle)
  - Data: Starts at ~40 KB (SQLite), grows with projects
- **Network**: Internet for first-run downloads (arduino-cli, QEMU binaries, library index)
- **Time**: First build ~10-15 minutes (includes ESP-IDF 4.4.7 compilation)

---

## Environment Setup

### Create .env File

The Velxio Docker Compose references `./backend/.env` for environment variables.

```bash
# Create the file
cat > backend/.env << 'EOF'
# ===== REQUIRED =====
# Change this in production to a random 32+ character string
SECRET_KEY=dev-key-change-in-production-use-random-string

# ===== DATABASE =====
# SQLite path (persistent volume)
DATABASE_URL=sqlite+aiosqlite:////app/data/velxio.db

# Project files storage directory
DATA_DIR=/app/data

# ===== FRONTEND ROUTING =====
# Where the frontend is hosted (for OAuth redirects)
# For localhost: http://localhost:3080
# For production: https://yourdomain.com
FRONTEND_URL=http://localhost:3080

# ===== GOOGLE OAUTH (Optional) =====
# Leave empty to disable Google login
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# OAuth callback URL (must match Google Console settings)
# Format: {FRONTEND_URL}/api/auth/google/callback
GOOGLE_REDIRECT_URI=http://localhost:3080/api/auth/google/callback

# ===== SECURITY =====
# Set to true if using HTTPS (production)
# false = HTTP (development)
COOKIE_SECURE=false
EOF
```

### Environment Variables Explained

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `SECRET_KEY` | Yes | — | JWT signing key. Change in production. Use `openssl rand -hex 32` to generate. |
| `DATABASE_URL` | No | `sqlite+aiosqlite:///./velxio.db` | SQLite connection string. Path must match volume mount. |
| `DATA_DIR` | No | `.` | Directory for project files. Must be writable. |
| `FRONTEND_URL` | No | `http://localhost:5173` | Frontend URL for OAuth and CORS. Must match browser origin. |
| `GOOGLE_CLIENT_ID` | No | — | Google OAuth client ID (from Google Console). Leave empty to disable. |
| `GOOGLE_CLIENT_SECRET` | No | — | Google OAuth client secret. |
| `GOOGLE_REDIRECT_URI` | No | `http://localhost:8001/api/auth/google/callback` | OAuth callback. Must match Google Console exactly. |
| `COOKIE_SECURE` | No | `false` | Set `true` for HTTPS (production only). |

---

## Docker Compose Configuration

### File: docker-compose.yml

The provided `docker-compose.yml` is production-grade and includes:

```yaml
services:
  velxio:
    build:
      context: .
      dockerfile: Dockerfile.standalone
    container_name: velxio-dev
    restart: unless-stopped
    ports:
      - "3080:80"
    env_file:
      - ./backend/.env
    environment:
      - DATABASE_URL=sqlite+aiosqlite:////app/data/velxio.db
      - DATA_DIR=/app/data
      - IDF_PATH=/opt/esp-idf
      - IDF_TOOLS_PATH=/root/.espressif
      - ARDUINO_ESP32_PATH=/opt/arduino-esp32
    volumes:
      - ./data:/app/data
      - arduino-libs:/root/.arduino15
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 90s
```

**Key Points:**

- **Multi-stage build** (see Dockerfile.standalone):
  - `qemu-provider`: Downloads QEMU binaries
  - `espidf-builder`: Builds ESP-IDF 4.4.7
  - `frontend-builder`: Builds React + Vite frontend
  - `final`: Python 3.12-slim runtime

- **Port mapping**: `3080:80` (nginx reverse proxy inside container)

- **Volumes**:
  - `./data:/app/data` — Project files and SQLite database
  - `arduino-libs:/root/.arduino15` — Arduino library cache (persistent across restarts)

- **Health check**: Every 30s via `curl http://localhost/health`

- **Restart policy**: `unless-stopped` (auto-restarts on crash)

---

## Deployment Steps

### Step 1: Prepare Repository

```bash
git clone https://github.com/davidmonterocrespo24/velxio.git
cd velxio
```

### Step 2: Create Environment File

```bash
cat > backend/.env << 'EOF'
SECRET_KEY=change-me-in-production-use-openssl-rand-hex-32
DATABASE_URL=sqlite+aiosqlite:////app/data/velxio.db
DATA_DIR=/app/data
FRONTEND_URL=http://localhost:3080
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:3080/api/auth/google/callback
COOKIE_SECURE=false
EOF
```

### Step 3: Build and Start Container

```bash
# Build and start (first run takes ~10-15 minutes)
docker compose up --build

# Or, start in background
docker compose up --build -d
```

**What happens:**
1. Downloads base images (Node 20, Ubuntu 22.04, Python 3.12-slim)
2. Compiles ESP-IDF 4.4.7 (takes ~5-10 minutes)
3. Builds React frontend (takes ~2-3 minutes)
4. Creates final image and starts container
5. Initializes arduino-cli and downloads library index

### Step 4: Verify Deployment

```bash
# Check container status
docker compose ps

# Should show:
# NAME         IMAGE           COMMAND                SERVICE   CREATED       STATUS                    PORTS
# velxio-dev   velxio-velxio   "/app/entrypoint.sh"   velxio    X seconds ago Up X seconds (health...)  0.0.0.0:3080->80/tcp
```

### Step 5: Access Velxio

Open your browser: `http://localhost:3080`

You should see the Velxio landing page with:
- "Create New Project" button
- Example projects (Blink, Traffic Light, etc.)
- Sign up / Login options

---

## Post-Deployment Tasks

### Create Default Project (Optional)

```bash
# Create a test project to verify compilation works
curl -X POST http://localhost:3080/api/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Blink",
    "board": "uno",
    "code": "#include <Arduino.h>\nvoid setup() { pinMode(13, OUTPUT); }\nvoid loop() { digitalWrite(13, HIGH); delay(1000); digitalWrite(13, LOW); delay(1000); }"
  }'
```

### Configure Google OAuth (Optional)

1. Go to {{< newtab "Google Cloud Console" "https://console.cloud.google.com/" >}}
2. Create a new project
3. Enable OAuth 2.0 Consent Screen
4. Create OAuth 2.0 Client ID (Web application)
5. Add authorized redirect URI:
   - Development: `http://localhost:3080/api/auth/google/callback`
   - Production: `https://yourdomain.com/api/auth/google/callback`
6. Copy Client ID and Secret to `.env`:
   ```bash
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-secret
   ```
7. Restart container:
   ```bash
   docker compose restart
   ```

### Set Up Regular Backups

```bash
# Backup SQLite database
docker exec velxio-dev cp /app/data/velxio.db /app/data/velxio-$(date +%Y%m%d).db.bak

# Or, backup entire data directory
tar -czf velxio-backup-$(date +%Y%m%d).tar.gz ./data/

# Automated daily backup (crontab)
0 2 * * * cd /path/to/velxio && tar -czf ./backups/velxio-$(date +\%Y\%m\%d).tar.gz ./data/ && find ./backups -name "*.tar.gz" -mtime +30 -delete
```

---

## Common Issues & Troubleshooting

### Issue: "address already in use" on port 3080

**Cause:** Another service is using port 3080.

**Fix:**
```bash
# Find what's using port 3080
lsof -i :3080

# Change port in docker-compose.yml
# ports:
#   - "8080:80"  # Use 8080 instead

docker compose down
docker compose up --build -d
```

### Issue: Container shows "unhealthy" in docker compose ps

**Cause:** Health check timeout (normal during startup, usually resolves).

**Check:**
```bash
# View health check logs
docker compose logs --tail=50 | grep -i health

# Test health endpoint directly
curl http://localhost:3080/health

# If it returns {"status":"healthy"}, container is fine
```

**If persistent unhealthy:**
```bash
# View full logs
docker compose logs --tail=100

# Restart container
docker compose restart

# Check if services are running
curl http://localhost:3080/  # Should return HTML
```

### Issue: Build fails with "E: Unable to locate package"

**Cause:** Ubuntu package mirror is slow or offline.

**Fix:**
```bash
# Rebuild with fresh image pull
docker compose down
docker system prune
docker compose up --build
```

### Issue: "Can't access http://localhost:3080"

**Cause:** Container not fully started or nginx misconfigured.

**Check:**
```bash
# Verify container is running
docker compose ps

# Check if nginx is responding
docker exec velxio-dev curl -s http://localhost/health

# View nginx logs
docker compose logs velxio-dev | grep -i nginx

# If all else fails, restart
docker compose restart
```

### Issue: Arduino compilation fails ("arduino-cli not found")

**Cause:** arduino-cli not installed in container.

**Note:** This shouldn't happen—it's auto-installed. If it does:
```bash
# Rebuild container
docker compose down
docker system prune -a
docker compose up --build
```

### Issue: ESP32 projects won't compile

**Cause:** ESP32 core not installed, or QEMU binary missing.

**Check:**
```bash
# View compiler logs
docker compose logs velxio-dev | grep -i "esp32\|qemu"

# Rebuild might be needed
docker compose down
docker compose up --build
```

---

## Performance Tuning

### Memory & CPU

**Typical usage (idle):**
- Memory: ~225 MB
- CPU: <1%

**During compilation:**
- Memory: ~500 MB (Arduino sketches) to ~2 GB (ESP32 with IDF)
- CPU: 100% (single core)

**Optimization:**

```yaml
# Limit memory if needed
deploy:
  resources:
    limits:
      memory: 1G
    reservations:
      memory: 512M
```

### Database Optimization

SQLite auto-vacuums and is fine for small projects (~100-1000 projects). For larger deployments, consider:

```bash
# Optimize SQLite
docker exec velxio-dev sqlite3 /app/data/velxio.db "VACUUM; PRAGMA optimize;"

# Or switch to PostgreSQL (modify DATABASE_URL)
# DATABASE_URL=postgresql+asyncpg://user:pass@postgres:5432/velxio
```

### Library Cache

Arduino libraries are cached in `/root/.arduino15` (mounted as `arduino-libs` volume).

```bash
# Clear cache if needed (will re-download on next compile)
docker compose down
docker volume rm velxio_arduino-libs
docker compose up
```

---

## Production Deployment

### Using docker-compose.prod.yml

For production, use the optimized config:

```bash
docker compose -f docker-compose.prod.yml up -d
```

**Key differences from dev:**
- Single production-optimized image (no dev dependencies)
- nginx configured for production (gzip, caching)
- Healthchecks tuned for production (longer start_period)
- Database optimized with WAL mode

### HTTPS Setup (Let's Encrypt + Nginx)

```bash
# Add to docker-compose.yml volumes:
volumes:
  - ./letsencrypt:/etc/letsencrypt
  - ./nginx.conf:/etc/nginx/nginx.conf
```

**nginx.conf:**

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Update .env for HTTPS:**

```bash
FRONTEND_URL=https://yourdomain.com
GOOGLE_REDIRECT_URI=https://yourdomain.com/api/auth/google/callback
COOKIE_SECURE=true
```

### Reverse Proxy (Caddy/Nginx)

If you have an existing reverse proxy:

```bash
# docker-compose.yml
ports:
  - "127.0.0.1:8080:80"  # Only accept from localhost
```

**Caddy (Caddyfile):**

```
yourdomain.com {
    reverse_proxy localhost:8080
    encode gzip
}
```

---

## Monitoring & Logging

### View Logs

```bash
# Real-time logs
docker compose logs -f

# Last 50 lines
docker compose logs --tail=50

# Specific service
docker compose logs velxio-dev

# Filter by keyword
docker compose logs | grep -i error
```

### Monitor Resource Usage

```bash
# Real-time stats
docker stats velxio-dev

# Or use one-off check
docker stats --no-stream
```

### Health Monitoring

```bash
# Check health every 10 seconds
watch -n 10 'docker compose ps'

# Or, alert if unhealthy
docker compose exec velxio-dev curl -s http://localhost/health | jq .
```

---

## Maintenance

### Regular Tasks

**Weekly:**
```bash
# Check for updates
docker pull ghcr.io/davidmonterocrespo24/velxio:master

# Backup database
docker exec velxio-dev cp /app/data/velxio.db /app/data/velxio-weekly.bak
```

**Monthly:**
```bash
# Rebuild with latest dependencies
docker compose down
docker system prune
docker compose up --build -d
```

### Upgrading Velxio

```bash
# Pull latest code
git pull

# Rebuild with new Dockerfile
docker compose down
docker compose up --build -d
```

### Database Maintenance

```bash
# Vacuum database (free unused space)
docker exec velxio-dev sqlite3 /app/data/velxio.db "VACUUM;"

# Check database integrity
docker exec velxio-dev sqlite3 /app/data/velxio.db "PRAGMA integrity_check;"

# Optimize indices
docker exec velxio-dev sqlite3 /app/data/velxio.db "PRAGMA optimize;"
```

---

## Persistence & Data

### What Gets Persisted

**Volume: `./data`**
- `velxio.db` — SQLite database (users, projects, auth state)
- `projects/{id}/` — Project source files (.ino, .py, metadata.json)

**Volume: `arduino-libs`**
- `/root/.arduino15/` — Arduino library cache (speeds up subsequent builds)

### Backup Strategy

```bash
#!/bin/bash
# backup-velxio.sh
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$TIMESTAMP"

mkdir -p "$BACKUP_DIR"

# Backup database
docker exec velxio-dev cp /app/data/velxio.db "$BACKUP_DIR/velxio.db"

# Backup projects
cp -r ./data/projects "$BACKUP_DIR/"

# Create tarball
tar -czf "./backups/velxio-$TIMESTAMP.tar.gz" -C "./backups" "$TIMESTAMP"

# Clean up temp
rm -rf "$BACKUP_DIR"

# Keep last 30 days of backups
find ./backups -name "*.tar.gz" -mtime +30 -delete

echo "Backup complete: ./backups/velxio-$TIMESTAMP.tar.gz"
```

**Run weekly:**
```bash
0 2 * * 0 cd /path/to/velxio && bash backup-velxio.sh
```

### Restore from Backup

```bash
# Extract backup
tar -xzf velxio-20260406_020000.tar.gz

# Stop container
docker compose down

# Restore files
cp -r 20260406_020000/projects ./data/
cp 20260406_020000/velxio.db ./data/

# Start container
docker compose up -d
```

---

## Testing Your Deployment

### Test 1: Access Frontend

```bash
curl -s http://localhost:3080/ | grep -q "<title>" && echo "✅ Frontend OK" || echo "❌ Frontend FAILED"
```

### Test 2: Health Check

```bash
curl -s http://localhost:3080/health | grep -q "healthy" && echo "✅ Health OK" || echo "❌ Health FAILED"
```

### Test 3: Compile Arduino Sketch

```bash
curl -X POST http://localhost:3080/api/compile/ \
  -H "Content-Type: application/json" \
  -d '{
    "code": "void setup() { Serial.begin(9600); } void loop() { Serial.println(\"Hello\"); delay(1000); }",
    "board": "uno"
  }' | jq .
```

### Test 4: Create Project

```bash
curl -X POST http://localhost:3080/api/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "board": "uno",
    "code": "void setup() {} void loop() {}",
    "public": false
  }' | jq .
```

---

## Real-World Notes

### Build Times

**First build** (with `--build`):
- Node dependencies: ~2 min
- ESP-IDF compilation: ~5-8 min
- Frontend build: ~2-3 min
- Final image creation: ~1 min
- **Total: ~10-15 minutes**

**Subsequent builds** (cached):
- Code changes only: ~1-2 min
- Dockerfile changes: ~5-10 min

**Start times:**
- Cold start (first run): ~90 seconds (arduino-cli initialization)
- Warm start (restart): ~10-30 seconds
- Health check passes: ~120 seconds (configured start_period)

### Observed Resource Usage

| Scenario | Memory | CPU | Notes |
|----------|--------|-----|-------|
| Idle | ~225 MB | <1% | Just nginx + FastAPI running |
| Arduino compile | ~600 MB | 100% | Single-threaded compilation |
| ESP32 compile | ~1.5-2 GB | 100% | Multiple cores, ESP-IDF heavy |
| 10 concurrent projects | ~400 MB | 20-50% | Depends on workload |

### Database Size

| Projects | Size | Notes |
|----------|------|-------|
| 0 (fresh) | 40 KB | SQLite overhead |
| 10 projects | ~200 KB | Minimal |
| 100 projects | ~1-2 MB | Still tiny |
| 1000 projects | ~10-20 MB | Still manageable |

---

## Summary Checklist

- ✅ Docker and Docker Compose installed
- ✅ Clone Velxio repository
- ✅ Create `backend/.env` with secrets
- ✅ Run `docker compose up --build` (15 min first time)
- ✅ Access http://localhost:3080
- ✅ Test example project (Blink)
- ✅ Configure Google OAuth (optional)
- ✅ Set up backups
- ✅ Configure HTTPS for production
- ✅ Monitor logs and health