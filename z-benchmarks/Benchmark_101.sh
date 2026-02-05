#!/bin/bash

# ============================================================
# Benchmark Script for Linux Systems
# ============================================================
# Usage: sudo ./Benchmark_101.sh
# Output: Creates timestamped log files in current directory
# ============================================================

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root (use sudo)." 1>&2
   exit 1
fi

# Save original directory and timestamp
LOG_DIR="$(pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "============================================"
echo "Starting Benchmark Suite - $TIMESTAMP"
echo "Logs will be saved to: $LOG_DIR"
echo "============================================"

# ============================================================
# STEP 1: System Information
# ============================================================
echo "[1/6] Collecting system information..."
{
    echo "=== System Information ==="
    echo ""
    echo "--- CPU Info ---"
    lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core|MHz"
    echo ""
    echo "--- Memory ---"
    free -h
    echo ""
    echo "--- Kernel ---"
    uname -a
    echo ""
    echo "--- Processor Count ---"
    nproc
} > "$LOG_DIR/system_info_$TIMESTAMP.txt"
echo "    Saved to system_info_$TIMESTAMP.txt"

# ============================================================
# STEP 2: Sysbench CPU Test
# ============================================================
echo "[2/6] Running sysbench CPU benchmark..."
{
    echo "=== Sysbench CPU Benchmark ==="
    apt-get install -y sysbench 2>&1
    echo ""
    echo "--- Single Thread ---"
    sysbench cpu --cpu-max-prime=20000 --threads=1 run
    echo ""
    echo "--- Multi Thread ($(nproc) threads) ---"
    sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run
} > "$LOG_DIR/sysbench_test_$TIMESTAMP.txt" 2>&1
echo "    Saved to sysbench_test_$TIMESTAMP.txt"

# ============================================================
# STEP 3: 7zip Compression Benchmark
# ============================================================
echo "[3/6] Running 7zip compression benchmark..."
{
    echo "=== 7zip Compression Benchmark ==="
    apt-get install -y p7zip-full 2>&1
    echo ""
    echo "--- All Threads ---"
    7z b -mmt
    echo ""
    echo "--- 4 Threads ---"
    7z b -mmt4
    echo ""
    echo "--- Single Thread ---"
    7z b -mmt1
} > "$LOG_DIR/7zip_test_$TIMESTAMP.txt" 2>&1
echo "    Saved to 7zip_test_$TIMESTAMP.txt"

# ============================================================
# STEP 4: Docker Build Benchmark
# ============================================================
echo "[4/6] Running Docker build benchmark..."
{
    echo "=== Docker Build Benchmark ==="
    
    # Clone test repository
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone --depth 1 https://github.com/JAlcocerT/Py_Trip_Planner/ 2>&1
    cd Py_Trip_Planner
    
    echo ""
    echo "--- Docker Pull (python:3.8) ---"
    { time docker pull python:3.8; } 2>&1
    
    echo ""
    echo "--- Docker Build (no cache) ---"
    { time docker build --no-cache -t pytripplanner-benchmark .; } 2>&1
    
    # Cleanup
    docker rmi pytripplanner-benchmark 2>/dev/null
    cd "$LOG_DIR"
    rm -rf "$TEMP_DIR"
    
    echo ""
    echo "Cleanup completed."
} > "$LOG_DIR/docker_build_$TIMESTAMP.txt" 2>&1
echo "    Saved to docker_build_$TIMESTAMP.txt"

# ============================================================
# STEP 5: Network Speed Test (Optional)
# ============================================================
echo "[5/6] Running network speed test..."
{
    echo "=== Network Speed Test ==="
    if ! command -v speedtest-cli &> /dev/null; then
        apt-get install -y speedtest-cli 2>&1
    fi
    speedtest-cli --simple 2>&1
} > "$LOG_DIR/network_test_$TIMESTAMP.txt" 2>&1
echo "    Saved to network_test_$TIMESTAMP.txt"

# ============================================================
# STEP 6: Disk I/O Benchmark
# ============================================================
echo "[6/6] Running disk I/O benchmark..."
{
    echo "=== Disk I/O Benchmark ==="
    
    echo "--- Write Speed (1GB) ---"
    dd if=/dev/zero of=/tmp/benchmark_testfile bs=1M count=1024 conv=fdatasync 2>&1
    
    echo ""
    echo "--- Read Speed ---"
    echo 3 > /proc/sys/vm/drop_caches  # Clear cache for accurate read test
    dd if=/tmp/benchmark_testfile of=/dev/null bs=1M 2>&1
    
    rm -f /tmp/benchmark_testfile
} > "$LOG_DIR/disk_io_$TIMESTAMP.txt" 2>&1
echo "    Saved to disk_io_$TIMESTAMP.txt"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "============================================"
echo "Benchmark Complete!"
echo "============================================"
echo "Results saved to:"
ls -la "$LOG_DIR"/*_$TIMESTAMP.txt
echo ""
echo "Quick Summary:"
echo "  - CPU: $(grep "events per second" "$LOG_DIR/sysbench_test_$TIMESTAMP.txt" | tail -1)"
echo "  - Network: $(cat "$LOG_DIR/network_test_$TIMESTAMP.txt" | grep "Download")"
