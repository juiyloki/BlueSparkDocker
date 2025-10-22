#!/bin/bash
set -e

# ----------------------------
# Load ROS 2 environment
# ----------------------------
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash 2>/dev/null || true

# ----------------------------
# Start ArduSub SITL
# ----------------------------
echo "=== Starting ArduSub SITL (Simple ROV 4) ==="
cd ~/ardupilot

# Launch ArduSub in SITL with simple4 frame
./build/sitl/bin/ardusub -S --model vectored --frame simple4 --speedup 1 \
    --serial0 tcp:0.0.0.0:5760,115200 &

SITL_PID=$!

# Wait for SITL TCP port to be open before starting MAVROS
echo "Waiting for SITL to be ready on port 5760..."
# Install netcat if needed
if ! command -v nc &> /dev/null; then
    echo "Netcat not found. Installing..."
    sudo apt update && sudo apt install -y netcat
fi

until nc -z localhost 5760; do
    sleep 1
done
echo "SITL ready!"

# ----------------------------
# Start MAVROS
# ----------------------------
echo "=== Starting MAVROS ==="
# Use the launch file that exists in your workspace
ros2 launch mavros test_compose.launch.py fcu_url:=tcp://localhost:5760 &

MAVROS_PID=$!

# ----------------------------
# Wait a few seconds for topics to come up
# ----------------------------
sleep 5

# ----------------------------
# List ROS 2 topics
# ----------------------------
echo "=== ROS 2 Topics ==="
ros2 topic list

# ----------------------------
# Keep script alive
# ----------------------------
echo "Simulation environment running. Press Ctrl+C to stop."
wait $SITL_PID $MAVROS_PID

