#!/bin/bash

# --- Configuration ---
ENV_FILE=".env"
CONTAINER_NAME="codex-container"
PROMPT_FILE="./orchestrator/prompts/prompt-init-userguide-iterative-cli.md" # Path to your markdown prompt file

# --- Load environment variables from .env file ---
echo "Attempting to load environment variables from: $ENV_FILE"

if [ -f "$ENV_FILE" ]; then
  while IFS='=' read -r key value; do
    if [[ ! -z "$key" && ! "$key" =~ ^# ]]; then
      key=$(echo "$key" | xargs)
      value=$(echo "$value" | xargs)
      if [[ "$value" =~ ^[\'\"](.*)[\'\"]$ ]]; then
        value="${BASH_REMATCH[1]}"
      fi
      export "$key=$value"
      echo "  Exported: $key"
    fi
  done < "$ENV_FILE"
  echo "Finished loading environment variables."
else
  echo "Error: .env file not found at '$ENV_FILE'. Please check the path and try again."
  exit 1
fi

# --- Read content of the prompt file ---
echo "Reading prompt from: $PROMPT_FILE"
if [ -f "$PROMPT_FILE" ]; then
  # Read the entire content of the file into a variable.
  # "$(cat "$PROMPT_FILE")" is robust for multi-line content.
  # We'll use printf %q to safely quote it for passing to bash -c
  PROMPT_CONTENT="$(cat "$PROMPT_FILE")"
  if [ -z "$PROMPT_CONTENT" ]; then
    echo "Warning: Prompt file '$PROMPT_FILE' is empty."
  fi
else
  echo "Error: Prompt file '$PROMPT_FILE' not found. Please ensure it exists."
  exit 1
fi

# --- Prepare environment variables for Docker exec ---
DOCKER_ENV_VARS=""
if [ -n "$OPENAI_API_KEY" ]; then DOCKER_ENV_VARS+="-e OPENAI_API_KEY "; fi
# Add more lines for any other variables you need from .env

# --- Construct the CODEX_COMMAND dynamically ---
# We need to correctly quote the PROMPT_CONTENT so it's treated as a single argument
# by codex inside the container.
# bash -c expects a single string argument.
# We will construct the command string for bash -c carefully.
# The `printf %q` is crucial here to handle special characters, spaces, and newlines in PROMPT_CONTENT.
QUOTED_PROMPT=$(printf "%q" "$PROMPT_CONTENT")
CODEX_COMMAND="codex ${QUOTED_PROMPT} --quiet --approval-mode full-auto"


# --- Execute the Docker command ---
echo "Executing command inside Docker container: $CONTAINER_NAME"
# Display the actual command that will be executed inside the container for debugging
echo "Inner container command: bash -c \"cd /app/input-sources && $CODEX_COMMAND\""

docker exec -t $DOCKER_ENV_VARS "$CONTAINER_NAME" bash -c "cd /app/input-sources && $CODEX_COMMAND"

if [ $? -eq 0 ]; then
  echo "Docker command executed successfully."
else
  echo "Docker command failed. Check the output above for errors."
fi