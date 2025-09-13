# Use ROS2 Humble desktop as base (Ubuntu 22.04)
FROM osrf/ros:humble-desktop1

# Metadata
LABEL maintainer="Agata"

# Update & install basic tools
RUN apt update && apt install -y \
    python3-colcon-common-extensions \
    python3-pip \
    git \
    wget \
    curl \
    lsb-release \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Setup ROS2 environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Create workspace folder
RUN mkdir -p /home/ros/ros2_ws/src
WORKDIR /home/ros/ros2_ws

# Default command when container runs
CMD ["/bin/bash"]

