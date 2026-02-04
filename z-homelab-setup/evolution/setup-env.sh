#!/bin/bash

# Configuration
ENV_FILE=".env"
SAMPLE_FILE=".env.sample"

# Function to generate a random password
generate_password() {
    openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16
}

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE already exists. Please delete it or back it up if you want to regenerate it."
    exit 1
fi

# Check if .env.sample exists
if [ ! -f "$SAMPLE_FILE" ]; then
    echo "Error: $SAMPLE_FILE not found. Please create it first."
    exit 1
fi

echo "Generating $ENV_FILE from $SAMPLE_FILE..."

# Generate random passwords
ROOT_PASS=$(generate_password)
USER_PASS=$(generate_password)

# Prompt for Trusted Domains
read -p "Enter Nextcloud Trusted Domains (space separated, e.g. 'http://[IP_ADDRESS] https://nc.example.com'): " TRUSTED_DOMAINS
if [ -z "$TRUSTED_DOMAINS" ]; then
    TRUSTED_DOMAINS="http://192.168.1.2"
    echo "No domains entered, defaulting to 'http://192.168.1.2'"
fi

# Create .env file by replacing placeholders or specific values
# Using a temp file to avoid partial writes
sed -e "s|^MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$ROOT_PASS|" \
    -e "s|^MYSQL_PASSWORD=.*|MYSQL_PASSWORD=$USER_PASS|" \
    -e "s|^NEXTCLOUD_TRUSTED_DOMAINS=.*|NEXTCLOUD_TRUSTED_DOMAINS=$TRUSTED_DOMAINS|" \
    "$SAMPLE_FILE" > "$ENV_FILE"

echo "Done! $ENV_FILE has been created with random passwords and your domains."
echo "------------------------------------------------"
echo "MYSQL_ROOT_PASSWORD: $ROOT_PASS"
echo "MYSQL_PASSWORD:      $USER_PASS"
echo "TRUSTED_DOMAINS:     $TRUSTED_DOMAINS"
echo "------------------------------------------------"
echo "Please review $ENV_FILE and adjust other variables if needed."
