# FastAPI app container with git and npm for build steps
FROM python:3.11-bullseye

# Install git, curl, npm (sufficient for npm ci/build), and certificates
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git curl ca-certificates npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies (explicit to avoid needing a build-system)
RUN pip install --no-cache-dir fastapi uvicorn[standard] python-dotenv httpx pydantic

# Copy app source
COPY . /app

# Expose service port (overridden by PORT env if needed)
EXPOSE 8055
ENV PORT=8055

# Default command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8055"]
