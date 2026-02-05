# Rill Self-Hosting Guide

> **Quick Start**: Get Rill running locally in under 5 minutes

This guide provides step-by-step instructions for self-hosting Rill on your local machine or server. 

Whether you prefer Docker or manual builds, this document covers everything you need.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (Recommended)](#quick-start-recommended)
- [Installation Methods](#installation-methods)
  - [Method 1: Official Install Script](#method-1-official-install-script)
  - [Method 2: Docker Deployment](#method-2-docker-deployment)
  - [Method 3: Manual Build from Source](#method-3-manual-build-from-source)
- [Running Your First Project](#running-your-first-project)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Advanced Setup](#advanced-setup)
- [Updating Rill](#updating-rill)
- [Uninstallation](#uninstallation)

---

## Prerequisites

### Minimum Requirements

- **OS**: Linux (x86_64, arm64), macOS (Intel, Apple Silicon)
- **RAM**: 2GB minimum, 4GB+ recommended
- **Disk**: 500MB for Rill, plus space for your data
- **Git**: Required for project management

### Optional (for development/building from source)

- **Docker** (20.10+) - for containerized deployment
- **Node.js** (20+) - for building the web UI
- **Go** (1.25+) - for building the backend
- **Buf** - for Protocol Buffer compilation

---

## Quick Start (Recommended)

The fastest way to get started is using the official install script:

```bash
# Install Rill
curl https://rill.sh | sh

# Start your first project
rill start my-rill-project
```

That's it! Rill will:


1. Download the latest binary for your platform
2. Install to `/usr/local/bin` (or your chosen location)
3. Launch a local server at `http://localhost:9009`

---

## Installation Methods

### Method 1: Official Install Script

#### Standard Installation

```bash
curl https://rill.sh | sh
```

**Install Locations:**
1. `/usr/local/bin/rill` (default, requires sudo)
2. `~/.rill/rill` (user directory, no sudo)
3. `./rill` (current directory)

#### Install Specific Version

```bash
# Install a specific version
curl https://rill.sh | sh -s -- --version v0.47.0

# Install nightly build
curl https://rill.sh | sh -s -- --nightly
```

#### Non-Interactive Installation

Useful for scripts/CI:

```bash
# Install to /usr/local/bin
curl https://rill.sh | sh -s -- --non-interactive /usr/local/bin latest

# Install to custom location
curl https://rill.sh | sh -s -- --non-interactive $HOME/.local/bin latest
```

#### macOS (Homebrew)

```bash
brew tap rilldata/tap
brew install rill
```

---

### Method 2: Docker Deployment

#### Using the Official Docker Image

**Build the Docker image** (from the project root):

```bash
# First, build the Rill binary
make

# Build the Docker image
docker build -t rill:latest .
```

**Run a Rill project in Docker**:

```bash
# Run Rill with a volume-mounted project
docker run -it --rm \
  -p 9009:9009 \
  -v $(pwd)/my-rill-project:/app/project \
  rill:latest start /app/project
```

#### Docker Compose Setup

Create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  rill:
    image: rill:latest
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "9009:9009"
    volumes:
      - ./my-rill-project:/app/project
      - rill-data:/home/rill/.rill
    command: ["start", "/app/project"]
    environment:
      - RILL_ENV=production

volumes:
  rill-data:
```

Start the service:

```bash
docker-compose up -d
```

---

### Method 3: Manual Build from Source

#### Step 1: Clone the Repository

```bash
git clone https://github.com/rilldata/rill.git
cd rill
```

#### Step 2: Install Dependencies

```bash
# Install Node.js dependencies
npm install

# Ensure you have Go 1.25+ installed
go version
```

#### Step 3: Build Rill

**Quick Build (CLI only, no UI)**:

```bash
make cli-only
```

**Full Build (with embedded UI and examples)**:

```bash
# This clones examples, builds web-local, and embeds everything
make
```

The binary will be output to `./rill` in the project root.

#### Step 4: Verify the Build

```bash
./rill version
```

---

## Running Your First Project

### Option 1: Start a New Project

```bash
rill start my-rill-project
```

Rill will:
- Create a new project directory
- Initialize with example configuration
- Start the runtime and web server
- Open `http://localhost:9009` in your browser

### Option 2: Use an Example Project

```bash
# Clone an example
git clone https://github.com/rilldata/rill-examples.git
cd rill-examples/rill-openrtb-prog-ads

# Start the project
rill start .
```

### Option 3: Import Existing Data

```bash
# Create a new project
mkdir my-project && cd my-project

# Initialize the project
rill init

# Add a data source (example: Parquet from S3)
cat > sources/orders.yaml <<EOF
type: source
connector: s3
uri: s3://my-bucket/orders.parquet
EOF

# Start the project
rill start .
```

---

## Configuration

### Project Configuration (`rill.yaml`)

Every Rill project has a `rill.yaml` file in the root:

```yaml
# Basic project configuration
title: My Analytics Project
description: Real-time analytics dashboard

# Default OLAP engine
olap_connector: duckdb

# Variables (can be overridden via env vars)
variables:
  warehouse_bucket: my-data-bucket
```

### Environment Variables

Configure Rill behavior via environment variables:

```bash
# Configure the runtime
export RILL_RUNTIME_INSTANCE_ID=my-instance
export RILL_RUNTIME_PORT=9009

# Configure DuckDB
export RILL_DUCKDB_MEMORY_LIMIT=4GB
export RILL_DUCKDB_THREADS=4

# Configure logging
export RILL_LOG_LEVEL=debug
```

### Credentials

Store credentials in `~/.rill/credentials.yaml`:

```yaml
# AWS credentials
aws:
  access_key_id: YOUR_ACCESS_KEY
  secret_access_key: YOUR_SECRET_KEY

# Google Cloud credentials
google:
  service_account_json: /path/to/service-account.json

# ClickHouse credentials
clickhouse:
  host: localhost:9000
  username: default
  password: ""
```

---

## Troubleshooting

### Issue: Port Already in Use

**Error**: `bind: address already in use`

**Solution**: Change the port:

```bash
rill start my-project --port 3000
```

### Issue: Git Not Found

**Error**: `Git could not be found`

**Solution**: Install Git:

```bash
# Ubuntu/Debian
sudo apt-get install git

# macOS
brew install git

# CentOS/RHEL
sudo yum install git
```

### Issue: Out of Memory

**Error**: DuckDB out of memory errors

**Solution**: Increase memory limit:

```bash
export RILL_DUCKDB_MEMORY_LIMIT=8GB
rill start my-project
```

### Issue: Permission Denied (Docker)

**Error**: `permission denied while trying to connect to the Docker daemon`

**Solution**: Add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Issue: Build Fails (Missing Dependencies)

**Error**: `command not found: buf` or similar

**Solution**: Install missing dependencies:

```bash
# Install Buf (on macOS)
brew install bufbuild/buf/buf

# Install Buf (on Linux)
curl -sSL https://github.com/bufbuild/buf/releases/download/v1.28.1/buf-Linux-x86_64 \
  -o /usr/local/bin/buf
chmod +x /usr/local/bin/buf
```

### Issue: DuckDB Extensions Not Loading

**Error**: Extensions fail to load

**Solution**: Pre-install DuckDB extensions:

```bash
# For native installation
rill runtime install-duckdb-extensions

# For Docker
docker run rill:latest runtime install-duckdb-extensions
```

### Issue: Node.js Out of Memory (Build Failure)

**Error**: `FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory`

**When**: Running `make` or `npm run build`

**Solution**: Increase Node.js heap size:

```bash
# Increase to 4GB
export NODE_OPTIONS="--max-old-space-size=4096"
make

# Or 8GB if you have the RAM
export NODE_OPTIONS="--max-old-space-size=8192"
make
```

**Better Solution**: Use the install script instead:

```bash
# Skip compilation entirely
curl https://rill.sh | sh
```

Building from source requires 4-8GB RAM for the frontend compilation. The install script downloads a pre-built binary, avoiding this issue entirely.

---

### Debug Mode

Enable verbose logging:

```bash
export RILL_LOG_LEVEL=debug
rill start my-project
```

Check logs:

```bash
# Logs are typically in:
~/.rill/logs/
```

---

## Advanced Setup

### Running Rill as a Service (systemd)

Create `/etc/systemd/system/rill.service`:

```ini
[Unit]
Description=Rill Analytics
After=network.target

[Service]
Type=simple
User=rill
WorkingDirectory=/opt/rill-projects/my-project
ExecStart=/usr/local/bin/rill start . --host 0.0.0.0 --port 9009
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable rill
sudo systemctl start rill
sudo systemctl status rill
```

### Using External ClickHouse

Configure ClickHouse as your OLAP engine:

```yaml
# rill.yaml
olap_connector: clickhouse

connectors:
  clickhouse:
    host: localhost:9000
    database: analytics
    username: default
    password: ""
```

### Multi-User Cloud Deployment

For production multi-user deployments, you'll need:

1. **Admin Service** - User/project management
2. **PostgreSQL** - Metadata storage
3. **Object Storage** - S3/GCS for file storage
4. **Runtime(s)** - Dynamically provisioned per project

Refer to the [ARCHITECTURE.md](file:///home/jalcocert/Desktop/rill/ARCHITECTURE.md) for details on cloud deployment architecture.

### Reverse Proxy (nginx)

Example nginx configuration:

```nginx
server {
    listen 80;
    server_name analytics.example.com;

    location / {
        proxy_pass http://localhost:9009;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## Updating Rill

### Update via Install Script

```bash
curl https://rill.sh | sh
```

### Update via Homebrew

```bash
brew upgrade rilldata/tap/rill
```

### Update Docker Image

```bash
# Rebuild from latest source
git pull
make
docker build -t rill:latest .
```

### Check Current Version

```bash
rill version
```

---

## Uninstallation

### Remove via Install Script

```bash
curl https://rill.sh | sh -s -- --uninstall
```

### Manual Removal

```bash
# Remove binary
sudo rm /usr/local/bin/rill
# or
rm ~/.rill/rill

# Remove configuration and data
rm -rf ~/.rill

# Remove PATH entries (if applicable)
# Edit ~/.bashrc or ~/.zshrc and remove the line:
# export PATH=$HOME/.rill:$PATH # Added by Rill install
```

### Remove via Homebrew

```bash
brew uninstall rilldata/tap/rill
brew untap rilldata/tap
```

---

## Additional Resources

- **Official Documentation**: [docs.rilldata.com](https://docs.rilldata.com/)
- **Architecture Guide**: [ARCHITECTURE.md](file:///home/jalcocert/Desktop/rill/ARCHITECTURE.md)
- **Examples**: [github.com/rilldata/rill-examples](https://github.com/rilldata/rill-examples)
- **Discord Community**: [discord.gg/2ubRfjC7Rh](https://discord.gg/2ubRfjC7Rh)
- **GitHub Issues**: [github.com/rilldata/rill/issues](https://github.com/rilldata/rill/issues)

---

## Quick Reference

### Common Commands

```bash
# Start a project
rill start my-project

# Initialize a new project
rill init

# Deploy to Rill Cloud
rill deploy

# Check version
rill version

# Get help
rill --help
```

### Default Ports

- **Web UI**: `http://localhost:9009`
- **Runtime API**: `http://localhost:9009/v1` (gRPC-Gateway)

### Directory Structure

```
~/.rill/
├── config.yaml       # User configuration
├── credentials.yaml  # Data source credentials
├── logs/            # Application logs
└── cache/           # DuckDB extensions, temp files
```

---

**Happy self-hosting! 🚀**

For questions or issues, join the [Discord community](https://discord.gg/2ubRfjC7Rh) or open an issue on [GitHub](https://github.com/rilldata/rill/issues).
