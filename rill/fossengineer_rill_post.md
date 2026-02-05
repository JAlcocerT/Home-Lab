# Rill: The Fastest Path from Data Lake to Dashboard (BI-as-Code)

If you've ever felt the pain of slow BI tools, complex data pipelines, or the "it works on my machine" dashboard syndrome, **Rill** is about to change your life. 

In this post, we’re diving into **Rill Architecture**, how it leverages **DuckDB**, and a step-by-step guide to self-hosting it (including the "gotchas" we solved along the way).

---

## What is Rill?

Rill is a **BI-as-code** platform.

It doesn't just display data; it treats your dashboards as version-controlled assets. 

### Why you should care:

- **Conversationally Fast**: Queries return in milliseconds thanks to an embedded **DuckDB** or **ClickHouse** engine.
- **BI-as-Code**: Your models are SQL, your metrics are YAML. Git-friendly and reproducible.
- **Universal Data Support**: Ingest from S3, GCS, local CSVs, or Parquet files with zero friction.
- **Automatic Profiling**: It profiles your data as you type your SQL.

---

## Architecture Deep Dive

Rill is built as a modular monorepo in **Go** and **SvelteKit**.

It consists of three primary layers:

1. **The CLI**: Your local interface. It embeds the entire web app and a local runtime server.
2. **The Runtime (Data Plane)**: The engine. It reconciles your code definitions with the actual data, handles ingestion, and executes queries.
3. **The Web UI (App Plane)**: A high-performance SvelteKit app for exploration and dashboarding.

### The Secret Sauce: DuckDB

Most BI tools query a remote database. Rill co-locates compute and data by embedding **DuckDB** (for small-to-medium datasets) directly. 

This eliminates the network round-trip for every slice-and-dice operation.

---

## How to Get It Running (The "What Worked" Guide)

We spent time building Rill from source and running it in Docker. Here is the definitive "FOSS Engineer" way to set it up.

### 1. Building from Source

Rill's frontend is massive (3,000+ dependencies). If you try a simple `make`, it might crash due to Node.js memory limits.

**The Fix:**
```bash
# Give Node.js 4GB of RAM for the build
export NODE_OPTIONS="--max-old-space-size=4096"
make
```

This generates a single standalone `./rill` binary—a marvel of engineering that contains the Go backend AND the embedded Sveltekit UI.

### 2. Running the Example
```bash
git clone https://github.com/rilldata/rill-examples.git
cd rill-examples/rill-github-analytics
../../rill start .
```
Rill will serve a dashboard at `http://localhost:9009` where you can explore real-time GitHub stats.

---

## Running Rill in Docker 🐳

If you prefer isolation, you can package that `./rill` binary into a container. 

### The Permission Gotcha
Docker containers often run as a specific user. In Rill's case, it uses a non-root user `rill` (UID 1001). When you mount a local directory, you might see `permission denied`.

**The Solution (Named Volumes):**
Named volumes let Docker manage permissions for you. Run it as `root` for initial setup and write access:

```bash
docker volume create rill-project

docker run -it --rm \
  -p 9009:9009 \
  -v rill-project:/app/project \
  --user root \
  rill:latest start /app/project
```

### Native vs. Docker
- **Native**: Best for local dev. Blazing fast.
- **Docker**: Best for private cloud or NAS deployments. Clean and isolated.

---

## Conclusion

Rill is part of the "Modern Data Stack" but feels like something from the future. 

By moving metrics into YAML and leveraging the power of DuckDB, it solves the "Dashboard lag" once and for all.

**Give it a try:**

```bash
curl https://rill.sh | sh
rill start my-project
```

*Happy Engineering!*
