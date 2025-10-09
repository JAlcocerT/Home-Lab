---
tags: ["TTS", "AI"]
---

# Coqui TTS

Coqui TTS is an open-source text-to-speech engine that provides high-quality, natural-sounding speech synthesis.

## Quick Start

1. Create a `docker-compose.yml` file with the following content:

```yaml
version: '3.8'

services:
  tts-cpu:
    image: ghcr.io/coqui-ai/tts-cpu
    container_name: coquitts
    ports:
      - "5002:5002"
    entrypoint: /bin/bash
    tty: true
    stdin_open: true
    # command: /bin/bash -c "python3 TTS/server/server.py --model_name tts_models/en/vctk/vits"
    
    # Optional: Mount a volume to persist data or access local files
    # volumes:
    #   - ./local_data:/data
```

2. Start the service:
   ```bash
   docker-compose up -d
   ```

## Access

Once started, you can access the TTS service at: `http://your-server-ip:5002`

## Usage

To start the TTS server with a specific model, uncomment and modify the `command` line in the docker-compose.yml file. For example:

```yaml
command: /bin/bash -c "python3 TTS/server/server.py --model_name tts_models/en/vctk/vits"
```

## Volumes

Uncomment and modify the volumes section if you need to:
- Persist downloaded models between container restarts
- Access local audio files
- Save generated speech files

## Notes

- The container runs in interactive mode with TTY enabled for development and testing
- For production use, you may want to set up proper authentication and rate limiting
- The service is tagged as "TTS" and "AI" for categorization
