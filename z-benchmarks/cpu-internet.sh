#!/bin/bash

# Save the timestamp for the log filenames
timestamp=$(date +"%Y%m%d_%H%M%S")

# Step 1: Save System Information (CPU info, uname, number of processors)
echo "Saving system information..." > system_info_$timestamp.txt
cat /proc/cpuinfo >> system_info_$timestamp.txt
uname -a >> system_info_$timestamp.txt
nproc >> system_info_$timestamp.txt
echo "System info saved to system_info_$timestamp.txt"

# Step 2: Install and test sysbench (CPU Test)
echo "Installing sysbench..." >> sysbench_test_$timestamp.txt
sudo apt install sysbench -y >> sysbench_test_$timestamp.txt 2>&1
echo "Running sysbench CPU test..." >> sysbench_test_$timestamp.txt
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run >> sysbench_test_$timestamp.txt 2>&1
echo "Sysbench test results saved to sysbench_test_$timestamp.txt"

# Step 3: Install 7zip and test compression
echo "Installing 7zip..." >> 7zip_test_$timestamp.txt
sudo apt-get install p7zip-full -y >> 7zip_test_$timestamp.txt 2>&1
echo "Running 7zip benchmark with multiple threads..." >> 7zip_test_$timestamp.txt
7z b -mmt >> 7zip_test_$timestamp.txt 2>&1
echo "Running 7zip benchmark with 4 threads..." >> 7zip_test_$timestamp.txt
7z b -mmt4 >> 7zip_test_$timestamp.txt 2>&1
echo "Running 7zip benchmark with single thread..." >> 7zip_test_$timestamp.txt
7z b >> 7zip_test_$timestamp.txt 2>&1
echo "7zip benchmark results saved to 7zip_test_$timestamp.txt"

# Step 4: 7zr Benchmark (Single Thread)
echo "Running 7zr benchmark with single thread..." >> 7zr_test_$timestamp.txt
7zr b -mmt1 >> 7zr_test_$timestamp.txt 2>&1
echo "7zr benchmark results saved to 7zr_test_$timestamp.txt"

# Step 5: Clone Py_Trip_Planner and build Docker image
echo "Cloning Py_Trip_Planner repository..." >> trip_planner_docker_build_$timestamp.txt
git clone https://github.com/JAlcocerT/Py_Trip_Planner/ >> trip_planner_docker_build_$timestamp.txt 2>&1
cd Py_Trip_Planner

echo "Running docker pull for python:3.8..." >> trip_planner_docker_build_$timestamp.txt
sudo bash -c 'time docker pull python:3.8' >> trip_planner_docker_build_$timestamp.txt 2>&1

echo "Building Docker image pytripplanner..." >> trip_planner_docker_build_$timestamp.txt
sudo bash -c 'time docker build --no-cache -t pytripplanner .' >> trip_planner_docker_build_$timestamp.txt 2>&1
echo "Docker build results saved to trip_planner_docker_build_$timestamp.txt"

# Step 6: Install Astral-sh Python Dependency Manager and run test
echo "Installing Cargo..." >> astral_sh_test_$timestamp.txt
sudo apt install cargo -y >> astral_sh_test_$timestamp.txt 2>&1

echo "Installing rye using cargo..." >> astral_sh_test_$timestamp.txt
time cargo install --git https://github.com/astral-sh/rye rye >> astral_sh_test_$timestamp.txt 2>&1
echo "Rye installation results saved to astral_sh_test_$timestamp.txt"

# Final message
echo "All tests completed. Results saved to respective text files."