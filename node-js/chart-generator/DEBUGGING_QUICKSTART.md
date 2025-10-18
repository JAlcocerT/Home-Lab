# Debugging Quick Start Guide

## 🚨 Something Not Working? Start Here!

### Step 1: Run Diagnostics
```bash
make troubleshoot
```
This will automatically check:
- ✅ Node.js and npm installation
- ✅ Dependencies
- ✅ Port availability
- ✅ File structure
- ✅ Server startup
- ✅ Health endpoint

### Step 2: Enable Debug Mode
```bash
make debug
```
This shows detailed logs including:
- All incoming requests
- Request/response bodies
- Validation errors
- Stack traces
- Performance metrics

### Step 3: Check Server Health
```bash
make test
```
Expected output:
```json
{
  "status": "healthy",
  "timestamp": "2025-10-18T11:30:45.123Z",
  "debug_mode": true,
  "log_level": "debug"
}
```

## 🔍 Common Problems & Solutions

### Problem: Port Already in Use
```
Error: listen EADDRINUSE: address already in use :::3001
```

**Solution:**
```bash
# Option 1: Kill the process using port 3001
kill $(lsof -t -i:3001)

# Option 2: Use a different port
PORT=8080 make debug
```

### Problem: Invalid JSON
```json
{
  "success": false,
  "error": "Invalid JSON format"
}
```

**Solution:** Check your JSON syntax
```bash
# Run in debug mode to see the exact error
make debug

# Common JSON mistakes:
# ❌ Single quotes: {'key': 'value'}
# ✅ Double quotes: {"key": "value"}

# ❌ Trailing comma: {"key": "value",}
# ✅ No trailing comma: {"key": "value"}
```

### Problem: Missing Chart Configuration
```json
{
  "success": false,
  "error": "Invalid chart configuration..."
}
```

**Solution:** Ensure both `series` and `options` are present
```json
{
  "series": [{
    "name": "Sales",
    "data": [30, 40, 35, 50]
  }],
  "options": {
    "chart": {
      "type": "line"
    }
  }
}
```

### Problem: Dependencies Not Installed
```
Error: Cannot find module 'express'
```

**Solution:**
```bash
npm install
```

## 🛠️ Debug Commands Reference

| Command | When to Use |
|---------|-------------|
| `make troubleshoot` | First step when something fails |
| `make debug` | Need detailed logs and stack traces |
| `make dev` | Developing and want auto-restart |
| `make test` | Quick health check |
| `make docker-debug` | Debugging Docker container |
| `make logs-debug` | View Docker logs with timestamps |

## 📊 Log Levels Explained

```bash
# DEBUG - See everything (recommended for troubleshooting)
make debug

# INFO - Normal operation (default)
make run

# WARN - Only warnings and errors
LOG_LEVEL=warn make run

# ERROR - Only errors
LOG_LEVEL=error make run
```

## 🐳 Docker Debugging

```bash
# Run container with debug output (foreground)
make docker-debug

# View logs from running container
make logs-debug

# Restart from scratch
make clean
make docker-up
```

## 📝 Example Debug Session

```bash
# 1. Check everything is OK
make troubleshoot

# 2. Start in debug mode
make debug

# Output shows:
[INFO] ============================================================
[INFO] ApexCharts Generator running at http://localhost:3001
[INFO] Debug Mode: ENABLED
[INFO] Log Level: debug
[INFO] Health Check: http://localhost:3001/health
[INFO] ============================================================

# 3. In another terminal, test the endpoint
curl -X POST http://localhost:3001/generate \
  -H "Content-Type: application/json" \
  -d '{
    "series": [{"name": "Test", "data": [1,2,3]}],
    "options": {"chart": {"type": "line"}}
  }'

# 4. Watch the debug logs in the first terminal
[DEBUG] Incoming POST request to /generate
[DEBUG] Request body: {...}
[DEBUG] Processing chart generation request
[INFO] Chart configuration validated successfully
[INFO] POST /generate - 200 (3ms)
```

## 🆘 Still Having Issues?

1. **Read the full guide:** `cat DEBUG.md`
2. **Check the logs:** Look for `[ERROR]` messages
3. **Verify your request:** Use curl or Postman to test
4. **Check the stack trace:** Points to the exact line with the issue

## 💡 Pro Tips

- Always start with `make troubleshoot` when debugging
- Use `make debug` to see what's actually happening
- Check `http://localhost:3001/health` to verify server is running
- In debug mode, error responses include helpful details
- Use `Ctrl+C` to stop the server gracefully

## 📚 More Resources

- Full debugging guide: [DEBUG.md](DEBUG.md)
- Environment variables: [.env.example](.env.example)
- Makefile commands: `make help`

---

**Quick Links:**
- Health Check: http://localhost:3001/health
- Main App: http://localhost:3001
