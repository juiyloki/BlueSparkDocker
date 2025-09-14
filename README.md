# BlueSpark Docker Environment

This repository provides a ready-to-use Docker environment for **ROS 2 Humble** with **PX4 Autopilot** and **Gazebo** simulation. The setup ensures a consistent environment for development and simulation across different machines.

---

## Table of Contents

- Features
- Prerequisites
- Setup
- Usage
- Workspace Configuration
- Cleaning Up
- License

---

## Features

- Ubuntu 22.04 base with **ROS 2 Humble Desktop**.
- PX4 Autopilot v1.14.3 with Python dependencies installed.
- Gazebo ROS integration and MAVROS support.
- GeographicLib datasets required by MAVROS pre-installed.
- Tools for building and running ROS 2 workspaces (`colcon`, `CMake`, `Ninja`).
- X11 forwarding for GUI applications (e.g., Gazebo, QtCreator).
- Configurable workspace path via `config.env`.

---

## Prerequisites

- Docker >= 20.10
- `xhost` installed (for X11 forwarding)
- Internet connection for initial image build and package installation.

---

## Setup

1. Clone this repository:


    git clone <https://github.com/juiyloki/BlueSparkDocker>
    cd <BlueSparkDocker>


2. Build the Docker image:


    ./build.sh


This will create a Docker image named `humble-sim:latest`.

---

## Usage

1. Configure workspace path (optional). By default, the workspace is `~/ros2_ws`. To customize, edit `config.env`:

    HOST_WS=~/my_custom_ws

2. Run the container:

    ./run.sh

- If the container already exists, it will start and attach to it.
- If not, a new container named `humble-sim` will be created.

3. Access the ROS 2 workspace inside the container:

    source /opt/ros/humble/setup.bash
    cd /home/ros/ros2_ws
    colcon build
    source install/setup.bash

Your host workspace is mounted inside the container at `/home/ros/ros2_ws`.

---

## Workspace Configuration

- PX4 repository is cloned to `/home/ros/PX4-Autopilot` with all dependencies installed.
- Python dependencies for PX4 are installed according to `Tools/setup/requirements.txt`.
- ROS 2 workspace structure:

    ros2_ws/
    └── src/

Mount your packages in `src/` to have them accessible in the container.

---

## Cleaning Up

Remove the container:

    ./clean.sh

Remove the Docker image:

    docker rmi humble-sim:latest

---

## License

This project is licensed under the Apache License 2.0. See the LICENSE file for details.

