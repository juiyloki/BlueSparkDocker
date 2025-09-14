# Use ROS2 Humble desktop as base (Ubuntu 22.04)
FROM osrf/ros:humble-desktop

# Metadata
LABEL maintainer="Agata"

# Prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update & install tools + ROS2/Gazebo/MAVROS
RUN apt-get update && apt-get install -y \
    python3-colcon-common-extensions \
    python3-pip \
    git \
    wget \
    curl \
    lsb-release \
    gnupg \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    ros-humble-mavros \
    ros-humble-mavros-extras \
    ros-humble-mavros-msgs \
    geographiclib-tools \
    && rm -rf /var/lib/apt/lists/*

# Install GeographicLib datasets (needed for MAVROS)
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && bash install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# Setup ROS2 environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Create workspace folder
RUN mkdir -p /home/ros/ros2_ws/src
WORKDIR /home/ros/ros2_ws

# Default command when container runs
CMD ["/bin/bash"]

