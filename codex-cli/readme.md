---
source_code: https://github.com/openai/codex/
---

This container provides an environment for running the OpenAI Codex CLI tool.

> It also [supports MCP](https://github.com/openai/codex/blob/main/docs/config.md)

1. Docker and Docker Compose installed
2. OpenAI API key from [OpenAI API Keys](https://platform.openai.com/api-keys)


1. Create a `.env` file in the project root with your OpenAI API key:

```
OPENAI_API_KEY=your-api-key-here
```

2. Build and start the container:

```bash
docker compose -f docker-compose.codex.yml up -d --build

# To stop the container (using either method):
# docker compose -f docker-compose.codex.yml down  # Using compose
# docker stop codex-container && docker rm codex-container  # Using container name
```

3. Access the container:

```bash
docker exec -it codex-container bash
```

- Your API key is passed securely via environment variables
- The container has persistent storage through the mapped volumes

Once inside the container, you can use the Codex CLI. Example:

```bash
# Get help
codex --help

# Process a file
codex process input.txt output.txt

# Interactive mode
codex chat
```


---

```sh
chmod +x run_codex.sh
#cd codex-cli-sage && git init
./run_codex.sh
```