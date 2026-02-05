---
title: "WrenAI: Self-Hostable GenBI That Turns Natural Language Into SQL"
date: 2026-02-05
draft: false
tags: ["GenBI", "Text-to-SQL", "Self-Hosted", "LLM", "Open Source", "Docker"]
description: "Deep dive into Wren AI - an open-source GenBI agent that converts natural language to SQL queries. Explore its architecture, self-hosting options, and why it's a game-changer for data teams."
---

# WrenAI: Self-Hostable GenBI That Turns Natural Language Into SQL

Ever wanted to query your database by just *asking* it questions in plain English? That's exactly what **Wren AI** does - and yes, you can self-host it.

I've been dissecting this project to understand its "DNA", and here's what I found.

---

## What is Wren AI?

Wren AI is an open-source **GenBI (Generative Business Intelligence)** agent that enables:

- 🗣️ **Text-to-SQL**: Ask questions in natural language, get accurate SQL
- 📊 **Text-to-Chart**: Auto-generate Vega visualizations
- 🧠 **Semantic Layer**: Understands your business context via MDL (Modeling Definition Language)

Think of it as a ChatGPT that actually understands your database schema.

**License**: AGPL-3.0 (copyleft - mods to network services must be open-sourced)

---

## The Architecture

Wren AI follows a microservices pattern with **6 Docker containers**:

```
┌─────────────────────────────────────────────────────────────┐
│                        USER PLANE                           │
│     wren-launcher (Go CLI)  ←→  Browser                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      CONTROL PLANE                          │
│   wren-ui (Next.js 14) ←→ SQLite/PostgreSQL                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         AI PLANE                            │
│  wren-ai-service (FastAPI) ←→ Qdrant (vectors) ←→ LLM      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                        DATA PLANE                           │
│     wren-engine ←→ ibis-server ←→ 12+ Data Sources          │
└─────────────────────────────────────────────────────────────┘
```

### The Components

| Service | What It Does | Tech Stack |
|---------|--------------|------------|
| **wren-ui** | Dashboard, chat interface, modeling UI | Next.js 14, TypeScript, Apollo GraphQL |
| **wren-ai-service** | LLM orchestration, Text-to-SQL pipelines | Python 3.12, FastAPI, Haystack AI |
| **wren-engine** | Semantic engine (parses MDL models) | External submodule |
| **ibis-server** | Universal data source connector | Python, Ibis framework |
| **qdrant** | Vector DB for semantic search | Qdrant v1.11.0 |
| **wren-launcher** | CLI installer | Go, Docker Compose SDK |

---

## How Text-to-SQL Works

Here's the actual flow when you ask a question:

1. **Question comes in** → wren-ui receives "Show me sales by region"
2. **Schema retrieval** → AI service queries Qdrant for relevant tables/columns via embeddings
3. **LLM call** → Prompt with schema context goes to OpenAI/Ollama/etc
4. **SQL generation** → LLM returns SQL candidate
5. **Validation** → wren-engine validates against MDL schema
6. **Correction loop** → If invalid, LLM gets error and retries (up to 3 times)
7. **Execution** → Valid SQL runs via ibis-server → actual database
8. **Results** → Data returns to UI, optional chart generated

The killer feature is that **40+ configurable pipelines** handle everything from schema indexing to chart generation.

---

## Self-Hosting: The Quick Way

```bash
# Clone
git clone https://github.com/Canner/WrenAI.git
cd WrenAI/docker

# Configure
cp .env.example .env.local
cp config.example.yaml config.yaml

# Set your LLM key
echo "OPENAI_API_KEY=sk-your-key" >> .env.local

# Launch
docker compose --env-file .env.local up -d

# Access at http://localhost:3000
```

That's it. 3 minutes to your own GenBI.

---

## LLM Flexibility

This is where Wren AI shines. It supports **10+ LLM providers** via LiteLLM:

- **Cloud**: OpenAI, Azure, Anthropic, Google Gemini, AWS Bedrock
- **Self-hosted**: Ollama, Groq, DeepSeek
- **Enterprise**: Databricks, Vertex AI

### Using Ollama (Fully Local)

Edit `config.yaml`:

```yaml
type: llm
provider: litellm_llm
models:
  - alias: default
    model: ollama/llama3.1:8b
    api_base: http://host.docker.internal:11434
```

Now your Text-to-SQL runs **entirely on your hardware**. No cloud API calls.

---

## Data Sources Supported

Out of the box:

| OLTP | OLAP | Cloud DW |
|------|------|----------|
| PostgreSQL | DuckDB | BigQuery |
| MySQL | ClickHouse | Snowflake |
| MSSQL | Trino | Redshift |
| Oracle | - | Databricks |

Plus Athena (via Trino).

---

## The Secret Sauce: Semantic Layer

What makes Wren AI actually *accurate* is the **MDL (Modeling Definition Language)**. Instead of the LLM guessing your schema, you define:

- Table relationships (foreign keys, joins)
- Business metrics (what "revenue" actually means)
- Column descriptions (not just `col_27`)

This context gets embedded into Qdrant and retrieved during every query, keeping the LLM grounded.

---

## When to Use Wren AI

✅ **Good fit**:
- Data teams tired of writing repetitive SQL
- Business users who need self-serve analytics
- Building AI assistants that need database access
- Replacing "ask the data analyst" bottlenecks

⚠️ **Consider alternatives if**:
- You need real-time streaming analytics
- Your schema changes constantly (requires re-indexing)
- You're on a very constrained edge device

---

## Production Considerations

For serious deployments:

1. **Use PostgreSQL** instead of SQLite for wren-ui
2. **External Qdrant cluster** for vector storage at scale
3. **Persistent volumes** - don't lose your embeddings
4. **Reverse proxy** (Nginx/Traefik) with HTTPS
5. **Disable telemetry** if handling sensitive data: `TELEMETRY_ENABLED=false`

Kubernetes manifests are included in `deployment/kustomizations/`.

---

## Final Thoughts

Wren AI represents a mature approach to GenBI:

- **Architecture**: Clean separation of concerns (AI plane, data plane, control plane)
- **Flexibility**: Swap LLMs without code changes
- **Self-hostable**: Full control, no vendor lock-in
- **Open source**: AGPL means community contributions flow back

If you're building anything that needs natural language → database queries, this is worth a look.

---

**Links**:
- [GitHub Repository](https://github.com/Canner/WrenAI)
- [Official Docs](https://docs.getwren.ai)
- [Discord Community](https://discord.gg/5DvshJqG8Z)

---

*Have you tried self-hosting GenBI tools? Let me know what your experience has been.*
