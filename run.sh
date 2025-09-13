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

# Allow X11 access for root
xhost +local:root

# Container name
CONTAINER_NAME="humble-sim"

# Check if container exists
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "Starting existing container '$CONTAINER_NAME'..."
    docker start -ai $CONTAINER_NAME
else
    echo "Creating and running new container '$CONTAINER_NAME'..."
    docker run -it \
        --name $CONTAINER_NAME \
        --net=host \
        -e DISPLAY=$DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "$HOST_WS":/home/ros/ros2_ws:rw \
        --device /dev/dri \
        --group-add video \
        humble-sim:latest
fi

