# ----------------------------
# Base
# ----------------------------
FROM osrf/ros:humble-desktop

LABEL maintainer="Agata"

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/rosuser
ENV USER=rosuser

# ----------------------------
# Create non-root user
# ----------------------------
RUN useradd -ms /bin/bash $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR $HOME

# ----------------------------
# Install dependencies
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
    sudo \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Upgrade pip and install Python tools
# ----------------------------
RUN pip3 install --upgrade pip
RUN pip3 install --break-system-packages "setuptools<68" wheel colcon-common-extensions

# ----------------------------
# GeographicLib datasets
# ----------------------------
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && bash install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# ----------------------------
# Setup ROS2 environment
# ----------------------------
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc

# ----------------------------
# Clone PX4 (ArduSub optional) inside Docker
# ----------------------------
USER $USER
WORKDIR $HOME
RUN git clone --branch v1.14.3 --recursive https://github.com/PX4/PX4-Autopilot.git

# Fix matplotlib for PX4 Python dependencies
WORKDIR $HOME/PX4-Autopilot
RUN sed -i 's/matplotlib>=3\.0\.\*/matplotlib>=3.0.0/' Tools/setup/requirements.txt && \
    pip3 install --break-system-packages -r Tools/setup/requirements.txt

# ----------------------------
# ArduPilot (ArduSub) inside Docker
# ----------------------------
WORKDIR $HOME
RUN git clone --recursive -b Sub-4.5 https://github.com/ArduPilot/ardupilot.git
WORKDIR $HOME/ardupilot
RUN git submodule update --init --recursive
RUN pip3 install pexpect
RUN ./waf configure --board sitl && ./waf build sub

# ----------------------------
# ROS2 workspace
# ----------------------------
RUN mkdir -p $HOME/ros2_ws/src
WORKDIR $HOME/ros2_ws

# ----------------------------
# Build MAVROS in ros2_ws
# ----------------------------
USER $USER
WORKDIR $HOME/ros2_ws/src

# Clone MAVROS
RUN git clone -b ros2 https://github.com/mavlink/mavros.git

WORKDIR $HOME/ros2_ws
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"


# ----------------------------
# --- Step 1 additions: ArduPilot Gazebo plugin ---
# ----------------------------
USER $USER
WORKDIR $HOME
RUN git clone -b gazebo11 https://github.com/ArduPilot/ardupilot_gazebo.git && \
    cd ardupilot_gazebo && mkdir build && cd build && \
    cmake -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_STANDARD_REQUIRED=ON -DCMAKE_CXX_EXTENSIONS=OFF .. && make -j$(nproc)


# --- Set environment paths for Gazebo ---
USER root
RUN echo '# ArduPilot Gazebo plugin setup' > /etc/profile.d/ardupilot_gazebo.sh && \
    echo 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/home/rosuser/ardupilot_gazebo/build' >> /etc/profile.d/ardupilot_gazebo.sh && \
    echo 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/home/rosuser/ardupilot_gazebo/models' >> /etc/profile.d/ardupilot_gazebo.sh && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/rosuser/ardupilot_gazebo/build' >> /etc/profile.d/ardupilot_gazebo.sh && \
    chmod +x /etc/profile.d/ardupilot_gazebo.sh

# Apply same exports to rosuser .bashrc for interactive shells
RUN echo 'source /etc/profile.d/ardupilot_gazebo.sh' >> $HOME/.bashrc && \
    chown $USER:$USER $HOME/.bashrc

USER $USER
WORKDIR $HOME

# ----------------------------
# Expose ports for SITL + MAVROS
# ----------------------------
EXPOSE 14550/udp
EXPOSE 14540/udp
EXPOSE 5760/tcp

# ----------------------------
# Default command
# ----------------------------
CMD ["/bin/bash"]

