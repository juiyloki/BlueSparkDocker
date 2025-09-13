# Use ROS2 Humble desktop as base (Ubuntu 22.04)
FROM osrf/ros:humble-desktop

# Metadata
LABEL maintainer="Agata"

# Prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update & install basic tools + Gazebo packages
RUN apt update && apt install -y \
    python3-colcon-common-extensions \
    python3-pip \
    git \
    wget \
    curl \
    lsb-release \
    gnupg \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    && apt update \
    && apt upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Setup ROS2 environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Create workspace folder
RUN mkdir -p /home/ros/ros2_ws/src
WORKDIR /home/ros/ros2_ws

# Default command when container runs
CMD ["/bin/bash"]

