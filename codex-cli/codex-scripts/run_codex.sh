#!/bin/bash


### THIS IS A TEST SCRIPT TO GET YOU FAMILIAR WITH HOW CODEX WORKS INSIDE A CONTAINER ###

# --- Configuration ---
ENV_FILE=".env" #Tweak this to the location of your .env file with OpenAI Key
CONTAINER_NAME="codex-container"

#With this command, it will just output a reply
#CODEX_COMMAND="codex \"Hello world!\""

#With any of these commands, it will write on the mapped volume to your local system
CODEX_COMMAND="codex \"Can you write a test.md file with hello world inside the folder docs?\""
#CODEX_COMMAND="codex \"Are you able to read the content of the test.md file inside the folder test?\""
#CODEX_COMMAND="codex \"Can you modify the test.md file and add a one liner about the hello world origin on the second line?\""
#CODEX_COMMAND="codex \"Given the posts inside /app/documentaition/src/content/docs/reference, can you inspect them and add valid markdown to the other posts where applicable? The hyperlink can be as /reference/<postfilename>\""


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

# --- Prepare environment variables for Docker exec ---
DOCKER_ENV_VARS=""
if [ -n "$OPENAI_API_KEY" ]; then DOCKER_ENV_VARS+="-e OPENAI_API_KEY "; fi
# Add more lines like the above for any other variables you need from .env

# --- Execute the Docker command ---
echo "Executing command inside Docker container: $CONTAINER_NAME"
echo "Command: docker exec -t $DOCKER_ENV_VARS $CONTAINER_NAME bash -c \"$CODEX_COMMAND\""

# No need for '-i' or 'echo "y" |' anymore, as codex handles non-interactivity itself
docker exec -t $DOCKER_ENV_VARS "$CONTAINER_NAME" bash -c "$CODEX_COMMAND"

if [ $? -eq 0 ]; then
  echo "Docker command executed successfully."
else
  echo "Docker command failed. Check the output above for errors."
fi