# Debugging Guide for ApexCharts Generator

This guide explains how to debug the ApexCharts Generator application when something fails.

## Table of Contents
- [Quick Start](#quick-start)
- [Debug Modes](#debug-modes)
- [Log Levels](#log-levels)
- [Common Issues](#common-issues)
- [Debugging Techniques](#debugging-techniques)
- [Health Check](#health-check)

## Quick Start

### Run in Debug Mode
```bash
# Using Make (recommended)
make debug

# Or directly with Node.js
DEBUG=true LOG_LEVEL=debug node server.js
```

### Run in Development Mode (with auto-restart)
```bash
# Install nodemon first (if not already installed)
npm install -g nodemon

# Run in dev mode
make dev
```

### Docker Debug Mode
```bash
# Run Docker container with debug output
make docker-debug

# Or view logs from running container
make logs-debug
```

## Debug Modes

### Environment Variables

| Variable | Values | Description |
|----------|--------|-------------|
| `DEBUG` | `true`/`false` | Enables debug mode with verbose logging |
| `NODE_ENV` | `development`/`production` | Sets the environment mode |
| `LOG_LEVEL` | `debug`/`info`/`warn`/`error` | Controls logging verbosity |
| `PORT` | Any number | Sets the server port (default: 3001) |

### Examples

```bash
# Maximum verbosity
DEBUG=true LOG_LEVEL=debug node server.js

# Production mode with warnings only
LOG_LEVEL=warn node server.js

# Custom port
PORT=8080 node server.js

# Combine multiple settings
DEBUG=true PORT=8080 LOG_LEVEL=debug node server.js
```

## Log Levels

The application supports 4 log levels (from most to least verbose):

### 1. DEBUG (Level 0)
Shows everything including:
- All incoming requests
- Request bodies
- Response times
- Detailed chart configurations
- Stack traces

```bash
LOG_LEVEL=debug node server.js
```

**Example output:**
```
[DEBUG] 2025-10-18T11:30:45.123Z Incoming GET request to /health
[DEBUG] 2025-10-18T11:30:45.124Z Health check requested
[INFO] 2025-10-18T11:30:45.125Z GET /health - 200 (2ms)
```

### 2. INFO (Level 1) - Default
Shows:
- Server startup information
- Successful operations
- Request/response summaries

```bash
LOG_LEVEL=info node server.js
# or just
node server.js
```

### 3. WARN (Level 2)
Shows only:
- Warnings
- Errors
- Invalid requests

```bash
LOG_LEVEL=warn node server.js
```

### 4. ERROR (Level 3)
Shows only:
- Errors
- Critical failures

```bash
LOG_LEVEL=error node server.js
```

## Common Issues

### Issue 1: Invalid JSON Format

**Symptom:**
```json
{
  "success": false,
  "error": "Invalid JSON format"
}
```

**Debug:**
```bash
# Run in debug mode to see the exact error
make debug

# The logs will show:
[ERROR] Invalid JSON in request body: Unexpected token...
```

**Solution:** Check your JSON syntax. Common mistakes:
- Missing quotes around keys
- Trailing commas
- Single quotes instead of double quotes

### Issue 2: Missing Chart Configuration

**Symptom:**
```json
{
  "success": false,
  "error": "Invalid chart configuration. Make sure to include \"series\" and \"options\" in your JSON."
}
```

**Debug in DEBUG mode:**
```json
{
  "success": false,
  "error": "Invalid chart configuration...",
  "received": ["someOtherKey"]  // Shows what keys were actually received
}
```

**Solution:** Ensure your POST request includes both `series` and `options`:
```json
{
  "series": [...],
  "options": {...}
}
```

### Issue 3: Wrong Data Types

**Symptom:**
```json
{
  "success": false,
  "error": "Series must be an array"
}
```

**Debug in DEBUG mode:**
```json
{
  "success": false,
  "error": "Series must be an array",
  "type_received": "string"  // Shows the actual type received
}
```

**Solution:** Make sure:
- `series` is an array: `"series": [...]`
- `options` is an object: `"options": {...}`

### Issue 4: Server Won't Start

**Debug steps:**
```bash
# 1. Check if port is already in use
lsof -i :3001

# 2. Try a different port
PORT=8080 make debug

# 3. Check for missing dependencies
npm install

# 4. Verify Node.js version
node --version  # Should be v12 or higher
```

### Issue 5: Docker Container Issues

**Debug steps:**
```bash
# 1. View container logs
make logs-debug

# 2. Check container status
docker-compose ps

# 3. Rebuild from scratch
make clean
make docker-up

# 4. Run in foreground with debug output
make docker-debug
```

## Debugging Techniques

### 1. Using the Health Check Endpoint

```bash
# Check if server is running
curl http://localhost:3001/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2025-10-18T11:30:45.123Z",
  "debug_mode": true,
  "log_level": "debug"
}

# Or use the Make command
make test
```

### 2. Testing Chart Generation

```bash
# Test with a valid chart configuration
curl -X POST http://localhost:3001/generate \
  -H "Content-Type: application/json" \
  -d '{
    "series": [{
      "name": "Sales",
      "data": [30, 40, 35, 50, 49, 60, 70]
    }],
    "options": {
      "chart": {
        "type": "line"
      }
    }
  }'
```

### 3. Monitoring Request/Response

In DEBUG mode, every request is logged:

```
[DEBUG] 2025-10-18T11:30:45.123Z Incoming POST request to /generate
[DEBUG] 2025-10-18T11:30:45.124Z Request body: {
  "series": [...],
  "options": {...}
}
[DEBUG] 2025-10-18T11:30:45.125Z Processing chart generation request
[INFO] 2025-10-18T11:30:45.126Z Chart configuration validated successfully
[DEBUG] 2025-10-18T11:30:45.127Z Chart config: {...}
[INFO] 2025-10-18T11:30:45.128Z POST /generate - 200 (5ms)
```

### 4. Viewing Stack Traces

When errors occur in DEBUG mode, full stack traces are logged:

```
[ERROR] 2025-10-18T11:30:45.123Z Error processing chart generation: Cannot read property 'length' of undefined
[ERROR] 2025-10-18T11:30:45.124Z Stack trace: Error: Cannot read property 'length' of undefined
    at /app/server.js:105:25
    at Layer.handle [as handle_request] (/app/node_modules/express/lib/router/layer.js:95:5)
    ...
```

### 5. Graceful Shutdown Testing

Test that the server shuts down properly:

```bash
# Start in debug mode
make debug

# In another terminal, send shutdown signal
kill -SIGTERM <pid>

# Or use Ctrl+C (SIGINT)
# You should see:
[INFO] SIGINT signal received: closing HTTP server
[INFO] HTTP server closed
```

## Advanced Debugging

### Using Node.js Inspector

```bash
# Start with Node.js debugger
node --inspect server.js

# Or with break on first line
node --inspect-brk server.js

# Then open Chrome and go to:
chrome://inspect
```

### Environment-Specific Debugging

Create a `.env` file for persistent debug settings:

```bash
# .env file
DEBUG=true
LOG_LEVEL=debug
PORT=3001
NODE_ENV=development
```

Then use with:
```bash
# Install dotenv
npm install dotenv

# Load environment variables (add to server.js)
require('dotenv').config();
```

### Debugging in Production

For production environments, use structured logging:

```bash
# Production mode with JSON logs (future enhancement)
NODE_ENV=production LOG_FORMAT=json node server.js
```

## Makefile Commands Reference

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make run` | Run normally (production mode) |
| `make debug` | Run with DEBUG mode enabled |
| `make dev` | Run with auto-restart on file changes |
| `make test` | Test the health endpoint |
| `make docker-debug` | Run Docker container in foreground with debug logs |
| `make logs` | View Docker container logs |
| `make logs-debug` | View Docker logs with timestamps |
| `make clean` | Stop and remove containers |

## Tips

1. **Always start with debug mode** when investigating issues
2. **Check the health endpoint** to verify the server is running
3. **Use curl or Postman** to test API endpoints directly
4. **Monitor response times** in the logs to identify performance issues
5. **Check stack traces** for the exact line where errors occur
6. **Use development mode** when actively developing to auto-restart on changes

## Getting Help

If you're still experiencing issues:

1. Run in debug mode: `make debug`
2. Reproduce the issue
3. Copy the relevant log output
4. Check the error message and stack trace
5. Refer to the [Common Issues](#common-issues) section
6. Review the code at the line number shown in the stack trace

## Example Debug Session

```bash
# 1. Start in debug mode
make debug

# Output:
[INFO] ============================================================
[INFO] ApexCharts Generator running at http://localhost:3001
[INFO] - Edit the JSON on the left to customize your chart
[INFO] - See the chart update in real-time on the right
[INFO] ============================================================
[INFO] Environment: production
[INFO] Debug Mode: ENABLED
[INFO] Log Level: debug
[INFO] Health Check: http://localhost:3001/health
[INFO] ============================================================
[DEBUG] Debug mode is active - verbose logging enabled
[DEBUG] Available endpoints:
[DEBUG]   GET  /health - Health check
[DEBUG]   POST /generate - Generate chart
[DEBUG]   GET  /* - Serve index.html

# 2. Test health endpoint
make test

# 3. Send a test request
curl -X POST http://localhost:3001/generate \
  -H "Content-Type: application/json" \
  -d '{"series": [], "options": {}}'

# 4. Watch the debug logs show every step
[DEBUG] Incoming POST request to /generate
[DEBUG] Request body: {"series": [], "options": {}}
[DEBUG] Processing chart generation request
[INFO] Chart configuration validated successfully
[DEBUG] Chart config: {"series": [], "options": {}}
[INFO] POST /generate - 200 (3ms)
```

---

**Last Updated:** 2025-10-18
**Version:** 1.0.0
