# What Worked: Building and Running Rill

This document captures the successful workflow for building and running Rill from source.

---

## The Successful Build Process

### Step 1: Increase Node.js Memory

**Required before building** to avoid heap out of memory errors:

```bash
export NODE_OPTIONS="--max-old-space-size=4096"
```

**Why?** The frontend build (SvelteKit + 3080 npm packages) requires 4-8GB of Node.js heap memory. Without this, the build will crash with `FATAL ERROR: Reached heap limit`.

### Step 2: Build from Source

```bash
cd /home/jalcocert/Desktop/rill
make
```

**What this does:**
1. Clones example projects from `rill-examples` repository
2. Runs `npm install` (downloads 3080+ packages)
3. Builds the SvelteKit frontend (`npm run build`)
4. Embeds the UI into the Go source code
5. Downloads DuckDB extensions for all platforms
6. Compiles the Go backend into a single `./rill` binary

**Time:** ~3.5 minutes (with sufficient memory)

**Output:** `./rill` binary in the project root

---

## Running Rill with Examples

### Clone Example Projects

```bash
cd /home/jalcocert/Desktop/rill
git clone https://github.com/rilldata/rill-examples.git
```

### Start the GitHub Analytics Example

```bash
cd rill-examples/rill-github-analytics
../../rill start .
```

**What happens:**
- Rill starts at `http://localhost:9009`
- It reconciles resources (loads data models)
- DuckDB processes the GitHub commit data
- Interactive dashboard becomes available

**To stop:** Press `Ctrl+C` twice

---

## Building the Docker Image

Once you have the `./rill` binary, build the container:

```bash
cd /home/jalcocert/Desktop/rill
docker build -t rill:latest .
```

**Time:** ~50 seconds

**Output:** Docker image `rill:latest`

---

## Native vs Container: Key Differences

### Running Natively (What You Did)

```bash
./rill start my-project
```

**Characteristics:**
- ✅ Binary runs directly on your host OS
- ✅ Access to full system resources
- ✅ Fastest performance (no container overhead)
- ✅ Easy debugging and development
- ✅ Files created in `~/.rill/` on your host
- ❌ Depends on your host environment
- ❌ Not isolated from other processes

**Use Cases:**
- Local development and exploration
- Quick testing and prototyping
- When you need maximum performance

---

### Running in Docker

```bash
docker run -it --rm \
  -p 9009:9009 \
  -v $(pwd)/my-project:/app/project \
  rill:latest start /app/project
```

**Characteristics:**
- ✅ Isolated from host system
- ✅ Reproducible environment
- ✅ Easy to deploy to cloud/Kubernetes
- ✅ No host dependencies (only Docker)
- ✅ Clean removal (just delete container)
- ❌ Slight performance overhead
- ❌ Requires volume mounts for data access
- ❌ More complex networking setup

**Use Cases:**
- Production deployments
- CI/CD pipelines
- Multi-tenant environments
- When you want complete isolation

---

## The Two-Stage Process Explained

### Why You Need Both `make` and `docker build`

**Stage 1: `make`** (builds the binary)

```
Source Code (Go + TypeScript)
         ↓
   npm run build (compiles frontend)
         ↓
   Embed UI + examples
         ↓
   go build (compiles backend)
         ↓
   Output: ./rill binary
```

**Stage 2: `docker build`** (packages the binary)

```
./rill binary (from Stage 1)
         ↓
   COPY into Ubuntu container
         ↓
   Install DuckDB extensions
         ↓
   Output: rill:latest Docker image
```

**Key Insight:** The Dockerfile does **NOT** build Rill. It **packages** the pre-built `./rill` binary into a container.

---

## Docker Permission Fix

### Problem: `Error: mkdir /app/project/tmp: permission denied`

**Cause:** The Dockerfile creates a non-root `rill` user (UID 1001) for security, but doesn't pre-create project directories with proper permissions.

**Working Solution: Use Named Volume + Run as Root**
```bash
# Create named volume
docker volume create rill-project

# Run as root (required for write permissions)
docker run -it --rm \
  -p 9009:9009 \
  -v rill-project:/app/project \
  --user root \
  rill:latest start /app/project
```

**Why `--user root`?** The current Dockerfile doesn't handle volume permissions properly. Running as root is the simplest workaround.

**Alternative: Pre-fix Volume Permissions** (More secure)
```bash
# Create volume
docker volume create rill-project

# Fix ownership first
docker run --rm \
  -v rill-project:/app/project \
  --user root \
  rill:latest sh -c "mkdir -p /app/project && chown -R rill:rill /app/project"

# Now run normally as rill user
docker run -it --rm \
  -p 9009:9009 \
  -v rill-project:/app/project \
  rill:latest start /app/project
```

**Data Persistence:**
- Your data is stored in the `rill-project` Docker volume
- Survives container restarts
- View with: `docker volume ls` and `docker volume inspect rill-project`

---

## Quick Reference

### Native Execution

```bash
# Build
export NODE_OPTIONS="--max-old-space-size=4096"
make

# Run
./rill start my-project
```

### Docker Execution

```bash
# Build (requires ./rill binary first)
docker build -t rill:latest .

# Create named volume
docker volume create rill-project

# Run (with permission fix)
docker run -it --rm \
  -p 9009:9009 \
  -v rill-project:/app/project \
  --user root \
  rill:latest start /app/project
```

---

## What You Achieved

✅ Built Rill from source (3.5 minutes)  
✅ Created a standalone `./rill` binary  
✅ Ran the GitHub Analytics example successfully  
✅ Built a Docker image  
✅ Understood the difference between native and container deployments

---

## Next Steps

**Option 1: Explore More Examples**

```bash
cd rill-examples/rill-openrtb-prog-ads
../../rill start .
```

**Option 2: Use Your Own Data**

```bash
mkdir ~/my-analytics && cd ~/my-analytics
~/Desktop/rill/rill init
# Add your data sources
~/Desktop/rill/rill start .
```

**Option 3: Install System-Wide**

```bash
sudo cp ./rill /usr/local/bin/
rill start my-project  # Now works from anywhere!
```

---

**Congratulations!** You successfully built and ran Rill from source. 🎉
