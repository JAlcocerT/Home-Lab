#!/bin/bash

# Troubleshooting script for ApexCharts Generator
# This script helps diagnose common issues

set -e

echo "=================================="
echo "ApexCharts Generator Troubleshooter"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Node.js
echo "1. Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js is installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js is not installed"
    echo "   Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check npm
echo ""
echo "2. Checking npm installation..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm is installed: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm is not installed"
    exit 1
fi

# Check dependencies
echo ""
echo "3. Checking dependencies..."
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} node_modules directory exists"
else
    echo -e "${YELLOW}⚠${NC} node_modules not found"
    echo "   Running: npm install"
    npm install
fi

# Check if port 3001 is available
echo ""
echo "4. Checking if port 3001 is available..."
if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Port 3001 is already in use"
    echo "   Process using port 3001:"
    lsof -Pi :3001 -sTCP:LISTEN
    echo ""
    echo "   Solutions:"
    echo "   - Stop the process: kill \$(lsof -t -i:3001)"
    echo "   - Use a different port: PORT=8080 make run"
else
    echo -e "${GREEN}✓${NC} Port 3001 is available"
fi

# Check server.js exists
echo ""
echo "5. Checking server.js..."
if [ -f "server.js" ]; then
    echo -e "${GREEN}✓${NC} server.js exists"
else
    echo -e "${RED}✗${NC} server.js not found"
    exit 1
fi

# Check public directory
echo ""
echo "6. Checking public directory..."
if [ -d "public" ]; then
    echo -e "${GREEN}✓${NC} public directory exists"
    if [ -f "public/index.html" ]; then
        echo -e "${GREEN}✓${NC} public/index.html exists"
    else
        echo -e "${RED}✗${NC} public/index.html not found"
    fi
else
    echo -e "${RED}✗${NC} public directory not found"
fi

# Check Docker (optional)
echo ""
echo "7. Checking Docker installation (optional)..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker is installed: $DOCKER_VERSION"
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version)
        echo -e "${GREEN}✓${NC} Docker Compose is installed: $COMPOSE_VERSION"
    else
        echo -e "${YELLOW}⚠${NC} Docker Compose is not installed"
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker is not installed (optional)"
fi

# Try to start the server in test mode
echo ""
echo "8. Testing server startup..."
echo "   Starting server in background for 3 seconds..."

# Start server in background
DEBUG=true LOG_LEVEL=debug node server.js > /tmp/chart-generator-test.log 2>&1 &
SERVER_PID=$!

# Wait a bit for server to start
sleep 3

# Check if server is still running
if ps -p $SERVER_PID > /dev/null; then
    echo -e "${GREEN}✓${NC} Server started successfully (PID: $SERVER_PID)"
    
    # Test health endpoint
    echo ""
    echo "9. Testing health endpoint..."
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Health endpoint is responding"
        echo ""
        echo "   Response:"
        curl -s http://localhost:3001/health | json_pp 2>/dev/null || curl -s http://localhost:3001/health
    else
        echo -e "${RED}✗${NC} Health endpoint is not responding"
    fi
    
    # Stop the test server
    echo ""
    echo "Stopping test server..."
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
else
    echo -e "${RED}✗${NC} Server failed to start"
    echo ""
    echo "Error log:"
    cat /tmp/chart-generator-test.log
fi

echo ""
echo "=================================="
echo "Troubleshooting Complete"
echo "=================================="
echo ""
echo "Next steps:"
echo "  - To run normally: make run"
echo "  - To run in debug mode: make debug"
echo "  - To run in dev mode: make dev"
echo "  - For more help: cat DEBUG.md"
echo ""

# Cleanup
rm -f /tmp/chart-generator-test.log
