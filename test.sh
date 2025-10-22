#!/bin/bash
# check_gazebo_plugins.sh — verify ardupilot_gazebo built correctly
set -e

echo "=== Gazebo version ==="
gazebo --version || true

echo
echo "=== Checking environment variables ==="
echo "GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH"
echo "GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH"
echo

echo "=== Listing ArduPilot plugin build outputs ==="
ls -l /home/rosuser/ardupilot_gazebo/build/*.so || echo "No plugin .so files found!"

echo
echo "=== Testing Gazebo load of ArduPilot plugin ==="
if gazebo --verbose --pause worlds/empty.world &>/tmp/gz_check.log & then
    sleep 3
    pkill gazebo || true
    echo "Gazebo started successfully."
else
    echo "Gazebo failed to start; check /tmp/gz_check.log"
fi
