# Debugging Features Changelog

## Version 1.0.0 - 2025-10-18

### 🎉 New Features Added

#### 1. **Enhanced Logging System**
- ✅ Multi-level logging (DEBUG, INFO, WARN, ERROR)
- ✅ Timestamp on every log entry
- ✅ Color-coded log levels
- ✅ Configurable via environment variables

#### 2. **Debug Mode**
- ✅ Enable via `DEBUG=true` environment variable
- ✅ Shows detailed request/response information
- ✅ Displays full stack traces on errors
- ✅ Logs request bodies and chart configurations
- ✅ Performance metrics (response time in ms)

#### 3. **Request/Response Middleware**
- ✅ Automatic logging of all HTTP requests
- ✅ Response time tracking
- ✅ Status code logging
- ✅ Request body logging in debug mode

#### 4. **Error Handling**
- ✅ Global error handler middleware
- ✅ JSON parse error handling
- ✅ Detailed error messages in debug mode
- ✅ Stack traces in debug mode
- ✅ Graceful error responses

#### 5. **Health Check Endpoint**
- ✅ New `/health` endpoint
- ✅ Returns server status
- ✅ Shows debug mode status
- ✅ Shows current log level
- ✅ Includes timestamp

#### 6. **Enhanced Validation**
- ✅ Better chart configuration validation
- ✅ Type checking for series and options
- ✅ Helpful error messages
- ✅ Debug info shows what was received

#### 7. **Graceful Shutdown**
- ✅ SIGTERM handler
- ✅ SIGINT handler (Ctrl+C)
- ✅ Proper server cleanup
- ✅ Unhandled rejection logging

#### 8. **Makefile Enhancements**
- ✅ `make debug` - Run with debug mode
- ✅ `make dev` - Development mode with auto-restart
- ✅ `make test` - Test health endpoint
- ✅ `make troubleshoot` - Run diagnostics
- ✅ `make docker-debug` - Docker debug mode
- ✅ `make logs-debug` - Docker logs with timestamps

#### 9. **Docker Support**
- ✅ Environment variable support in docker-compose
- ✅ Debug mode for Docker containers
- ✅ Configurable log levels
- ✅ Port configuration

#### 10. **Documentation**
- ✅ Comprehensive DEBUG.md guide
- ✅ Quick start guide (DEBUGGING_QUICKSTART.md)
- ✅ Environment variable examples (.env.example)
- ✅ Troubleshooting script (troubleshoot.sh)

### 📝 Modified Files

1. **server.js**
   - Added logger utility with 4 log levels
   - Added request/response logging middleware
   - Added health check endpoint
   - Enhanced error handling
   - Added graceful shutdown handlers
   - Improved startup logging

2. **Makefile**
   - Added `debug` target
   - Added `dev` target
   - Added `test` target
   - Added `troubleshoot` target
   - Added `docker-debug` target
   - Added `logs-debug` target

3. **docker-compose.yml**
   - Added environment variable support
   - Added DEBUG variable
   - Added LOG_LEVEL variable
   - Added NODE_ENV variable

### 📄 New Files Created

1. **DEBUG.md** - Comprehensive debugging guide
   - Table of contents
   - Quick start section
   - Debug modes explanation
   - Log levels documentation
   - Common issues and solutions
   - Debugging techniques
   - Advanced debugging
   - Makefile commands reference

2. **DEBUGGING_QUICKSTART.md** - Quick reference guide
   - Step-by-step troubleshooting
   - Common problems and solutions
   - Debug commands reference
   - Example debug session
   - Pro tips

3. **.env.example** - Environment configuration template
   - All available environment variables
   - Usage examples
   - Comments explaining each option

4. **troubleshoot.sh** - Automated diagnostic script
   - Checks Node.js installation
   - Checks npm installation
   - Verifies dependencies
   - Tests port availability
   - Validates file structure
   - Tests server startup
   - Tests health endpoint

5. **CHANGELOG_DEBUG.md** - This file
   - Complete list of changes
   - Feature documentation

### 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `false` | Enable debug mode |
| `NODE_ENV` | `production` | Environment mode |
| `LOG_LEVEL` | `info` | Logging verbosity |
| `PORT` | `3001` | Server port |

### 🚀 Usage Examples

#### Run in Debug Mode
```bash
make debug
```

#### Run in Development Mode
```bash
make dev
```

#### Run Diagnostics
```bash
make troubleshoot
```

#### Test Health Endpoint
```bash
make test
```

#### Docker Debug Mode
```bash
make docker-debug
```

#### Custom Configuration
```bash
DEBUG=true LOG_LEVEL=debug PORT=8080 node server.js
```

### 📊 Log Output Examples

#### Normal Mode (INFO level)
```
[INFO] 2025-10-18T11:30:45.123Z ApexCharts Generator running at http://localhost:3001
[INFO] 2025-10-18T11:30:50.456Z POST /generate - 200 (5ms)
```

#### Debug Mode (DEBUG level)
```
[DEBUG] 2025-10-18T11:30:45.123Z Incoming POST request to /generate
[DEBUG] 2025-10-18T11:30:45.124Z Request body: {"series": [...], "options": {...}}
[DEBUG] 2025-10-18T11:30:45.125Z Processing chart generation request
[INFO] 2025-10-18T11:30:45.126Z Chart configuration validated successfully
[DEBUG] 2025-10-18T11:30:45.127Z Chart config: {...}
[INFO] 2025-10-18T11:30:45.128Z POST /generate - 200 (5ms)
```

#### Error with Debug Mode
```
[ERROR] 2025-10-18T11:30:45.123Z Error processing chart generation: Cannot read property 'length' of undefined
[ERROR] 2025-10-18T11:30:45.124Z Stack trace: Error: Cannot read property...
    at /app/server.js:105:25
    at Layer.handle [as handle_request] (/app/node_modules/express/lib/router/layer.js:95:5)
```

### 🎯 Benefits

1. **Faster Debugging** - Detailed logs help identify issues quickly
2. **Better Error Messages** - Clear, actionable error information
3. **Production Ready** - Different log levels for different environments
4. **Developer Friendly** - Auto-restart in dev mode
5. **Easy Diagnostics** - Automated troubleshooting script
6. **Docker Support** - Debug mode works in containers
7. **Health Monitoring** - Built-in health check endpoint
8. **Graceful Shutdown** - Proper cleanup on exit

### 🔄 Backward Compatibility

All changes are backward compatible:
- Default behavior unchanged (INFO level logging)
- No breaking changes to API
- Existing functionality preserved
- Optional debug features

### 📚 Documentation

- **Full Guide**: [DEBUG.md](DEBUG.md)
- **Quick Start**: [DEBUGGING_QUICKSTART.md](DEBUGGING_QUICKSTART.md)
- **Environment Config**: [.env.example](.env.example)
- **Commands**: `make help`

### 🧪 Testing

To verify the debugging features:

```bash
# 1. Run diagnostics
make troubleshoot

# 2. Start in debug mode
make debug

# 3. Test health endpoint
make test

# 4. Send a test request
curl -X POST http://localhost:3001/generate \
  -H "Content-Type: application/json" \
  -d '{"series": [], "options": {}}'

# 5. Verify logs show detailed information
```

### 🎓 Learning Resources

1. Read [DEBUGGING_QUICKSTART.md](DEBUGGING_QUICKSTART.md) for common issues
2. Read [DEBUG.md](DEBUG.md) for comprehensive guide
3. Run `make troubleshoot` to diagnose problems
4. Use `make debug` to see what's happening
5. Check `/health` endpoint to verify server status

---

**Author:** Cascade AI  
**Date:** 2025-10-18  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
