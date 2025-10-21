#!/bin/bash

# Container name
CONTAINER_NAME="humble-submarine"

# Mount optional workspace
HOST_WS=${HOST_WS:-$HOME/ros2_ws}

# Ensure folder exists
mkdir -p "$HOST_WS/src"

# Allow X11 access for root
xhost +local:root

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
        -v "$HOST_WS":/home/rosuser/ros2_ws:rw \
        --device /dev/dri \
        --group-add video \
        humble-submarine:latest
fi

