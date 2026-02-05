# Self-Hosting Wren AI

This guide covers deploying Wren AI in your own infrastructure.

---

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Docker | 20.10+ | With Compose v2 |
| RAM | 8GB+ | 16GB recommended for larger schemas |
| CPU | 2 cores+ | 4+ for production |
| Disk | 10GB+ | More for vector storage at scale |
| LLM API Key | - | OpenAI, Azure, Anthropic, or Ollama |

---

## Quick Start (Docker Compose)

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/Canner/WrenAI.git
cd WrenAI/docker

# Create environment file
cp .env.example .env.local

# Create AI config
cp config.example.yaml config.yaml
```

### 2. Set Required Variables

Edit `.env.local`:

```bash
# REQUIRED: Your LLM API key
OPENAI_API_KEY=sk-your-key-here

# Optional: Change exposed port (default 3000)
HOST_PORT=3000
```

### 3. Start Services

```bash
# Start all services
docker compose --env-file .env.local up -d

# Check status
docker compose ps

# View logs
docker compose logs -f wren-ai-service
```

### 4. Access UI

Open `http://localhost:3000` in your browser.

---

## Alternative LLM Configurations

### Using Ollama (Local LLM)

1. Start Ollama with a model:
   ```bash
   ollama run llama3.1:8b
   ```

2. Update `config.yaml`:
   ```yaml
   type: llm
   provider: litellm_llm
   models:
     - alias: default
       model: ollama/llama3.1:8b
       api_base: http://host.docker.internal:11434
   ```

3. Update embedder (use Ollama embedding model):
   ```yaml
   type: embedder
   provider: litellm_embedder
   models:
     - model: ollama/nomic-embed-text
       api_base: http://host.docker.internal:11434
   ```

### Using Azure OpenAI

```yaml
type: llm
provider: litellm_llm
models:
  - alias: default
    model: azure/your-deployment-name
    api_base: https://your-resource.openai.azure.com
    api_key: ${AZURE_API_KEY}
    api_version: "2024-02-01"
```

### Using Google Gemini

Set `GOOGLE_API_KEY` in `.env.local`, then:

```yaml
type: llm
provider: litellm_llm
models:
  - alias: default
    model: gemini/gemini-1.5-pro
```

---

## Production Deployment

### Using External PostgreSQL

By default, wren-ui uses SQLite. For production, use PostgreSQL:

1. Set environment in `docker-compose.yaml`:
   ```yaml
   wren-ui:
     environment:
       DB_TYPE: pg
       PG_URL: postgresql://user:pass@postgres:5432/wrenai
   ```

### Persistent Storage

Ensure the `data` volume persists across restarts:

```yaml
volumes:
  data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/to/persistent/storage
```

### Resource Limits

```yaml
wren-ai-service:
  deploy:
    resources:
      limits:
        memory: 4G
        cpus: '2.0'
```

### Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl;
    server_name wren.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

---

## Kubernetes Deployment

Kustomize configurations are available in `deployment/kustomizations/`:

```bash
cd deployment/kustomizations

# Apply base configuration
kubectl apply -k base/

# Or apply with overlays
kubectl apply -k overlays/production/
```

---

## Environment Variables Reference

### Required

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | LLM provider API key (or equivalent for other providers) |

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST_PORT` | `3000` | UI exposed port |
| `AI_SERVICE_FORWARD_PORT` | `5555` | AI service exposed port |
| `PLATFORM` | `linux/amd64` | Docker platform (use `linux/arm64` for Apple Silicon) |
| `GENERATION_MODEL` | `gpt-4o-mini` | Default LLM model for telemetry |

### Telemetry

| Variable | Default | Description |
|----------|---------|-------------|
| `TELEMETRY_ENABLED` | `true` | Send anonymous usage data |
| `LANGFUSE_ENABLE` | `true` | LLM observability |
| `LANGFUSE_SECRET_KEY` | - | Langfuse credentials |
| `LANGFUSE_PUBLIC_KEY` | - | Langfuse credentials |

### Advanced

| Variable | Default | Description |
|----------|---------|-------------|
| `SHOULD_FORCE_DEPLOY` | `1` | Auto-deploy on startup |
| `QDRANT_HOST` | `qdrant` | Vector DB host |
| `EXPERIMENTAL_ENGINE_RUST_VERSION` | `false` | Use experimental Rust engine |

---

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker compose logs wren-ai-service
docker compose logs wren-ui
```

Common issues:
- Missing `OPENAI_API_KEY`
- Port conflicts (change `HOST_PORT`)
- Qdrant not ready (increase timeout in entrypoint)

### Slow Response Times

- Use a faster LLM model (e.g., `gpt-4o-mini` vs `gpt-4o`)
- Check Qdrant memory usage
- Ensure Docker has enough allocated memory

### Permission Errors

Ensure volume permissions:
```bash
# Check UID/GID of container user
docker compose exec wren-ui id

# Fix host permissions
sudo chown -R 1000:1000 /path/to/data
```

### LLM Errors

Enable debug logging in `config.yaml`:
```yaml
settings:
  logging_level: DEBUG
  development: true
```

---

## Upgrading

```bash
# Pull latest images
docker compose pull

# Restart with new versions
docker compose down
docker compose --env-file .env.local up -d

# Check migration status
docker compose logs wren-ui | grep -i migrat
```

---

## Backup & Restore

### Backup

```bash
# Stop services
docker compose down

# Backup SQLite database
cp data/db.sqlite3 backup/

# Backup Qdrant vectors
tar -czf backup/qdrant.tar.gz data/qdrant/
```

### Restore

```bash
# Restore database
cp backup/db.sqlite3 data/

# Restore vectors
tar -xzf backup/qdrant.tar.gz -C data/

# Start services
docker compose up -d
```

---

## Security Considerations

> [!CAUTION]
> Wren AI is licensed under AGPL-3.0. If you modify the source and expose it over a network, you must open-source your modifications.

- **API Keys**: Never commit `.env.local` or `config.yaml` with secrets
- **Network**: Run behind a reverse proxy with HTTPS in production
- **Telemetry**: Disable if handling sensitive data with `TELEMETRY_ENABLED=false`
