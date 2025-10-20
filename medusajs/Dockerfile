# Medusa server container
# Builds a lightweight runtime that bootstraps a Medusa app into /server on first run

FROM node:20-alpine

# Install bash, curl, git for bootstrap convenience
RUN apk add --no-cache bash curl git

WORKDIR /server

# Copy bootstrap script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose Medusa default port
EXPOSE 9000

# Use a non-root user for better security
RUN addgroup -S medusa && adduser -S medusa -G medusa
USER medusa

# Start script handles install/migrate/start
CMD ["/start.sh"]
