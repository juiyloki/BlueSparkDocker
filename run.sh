#!/bin/bash

# Default workspace path (from ROS2 Humble tutorials)
DEFAULT_WS=~/ros2_ws

# Load config.env if it exists
if [ -f ./config.env ]; then
    source ./config.env
    echo "Using workspace path from config.env: $HOST_WS"
else
    HOST_WS=$DEFAULT_WS
    echo "config.env not found. Using default workspace path: $HOST_WS"
fi

# Ensure folder exists
mkdir -p "$HOST_WS/src"

# Run the container
docker run -it \
    --name humble-sim \
    --net=host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$HOST_WS":/home/ros/ros2_ws:rw \
    --device /dev/dri \
    --group-add video \
    humble-sim:latest

