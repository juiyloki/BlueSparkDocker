# Use ROS2 Humble desktop as base (Ubuntu 22.04)
FROM osrf/ros:humble-desktop

LABEL maintainer="Agata"

# Prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------
# Install apt dependencies
# ----------------------------
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
    build-essential \
    ninja-build \
    cmake \
    python3-dev \
    python3-venv \
    python3-numpy \
    python3-yaml \
    python3-empy \
    python3-toml \
    python3-pygments \
    python3-setuptools \
    python3-wheel \
    python3-jinja2 \
    libpython3-dev \
    libxml2-utils \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    qtcreator \
    genromfs \
    zip \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Upgrade pip and tools
# ----------------------------
RUN pip3 install --upgrade pip setuptools wheel

# ----------------------------
# Remove distutils-installed packages that conflict with PX4
# ----------------------------
RUN apt remove -y python3-sympy python3-mpmath || true

# ----------------------------
# Install pyulog
# ----------------------------
RUN pip3 install pyulog

# ----------------------------
# Install GeographicLib datasets (needed by MAVROS)
# ----------------------------
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && bash install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# ----------------------------
# Setup ROS2 environment
# ----------------------------
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# ----------------------------
# Clone PX4 repository
# ----------------------------
WORKDIR /home/ros
RUN git clone https://github.com/PX4/PX4-Autopilot.git --branch v1.14.3 --recursive

# ----------------------------
# Fix matplotlib version & install PX4 Python dependencies
# ----------------------------
WORKDIR /home/ros/PX4-Autopilot
RUN sed -i 's/matplotlib>=3\.0\.\*/matplotlib>=3.0.0/' Tools/setup/requirements.txt \
    && pip3 install --break-system-packages -r Tools/setup/requirements.txt

# ----------------------------
# Create ROS2 workspace folder
# ----------------------------
RUN mkdir -p /home/ros/ros2_ws/src
WORKDIR /home/ros/ros2_ws

# ----------------------------
# Default command
# ----------------------------
CMD ["/bin/bash"]

