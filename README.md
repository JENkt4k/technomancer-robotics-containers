# Technomancer Robotics Containers

Container scaffold for ROS 2 Jazzy, Gazebo Harmonic, NVIDIA GPU passthrough, CPU AI nodes, and robot runtime deployment.

The first working demo is a small TurtleBot-style differential-drive robot in Gazebo Harmonic with ROS 2 Jazzy bridge topics for `/clock`, `/scan`, odometry, and velocity commands.

## Prerequisites

- Docker Engine with the Docker Compose v2 plugin.
- A Linux host, WSL2 distro, or other environment that can run Linux containers with host networking.
- For graphical Gazebo clients on Linux: X11 access, usually `xhost +local:root`.
- For NVIDIA runs: NVIDIA driver plus NVIDIA Container Toolkit.
- Optional but recommended: build the Technomancer images before first use:

```bash
bash scripts/build-all.sh
```

The demo scripts also pass `--build`, so they can build the needed image on first run.

## CPU TurtleBot Demo

```bash
bash scripts/up-turtlebot-cpu.sh
```

This starts the `turtlebot-demo` service from `compose/compose.cpu.yml` using `technomancer-ros-gazebo-cpu:jazzy-harmonic`.

## NVIDIA TurtleBot Demo

```bash
xhost +local:root
bash scripts/up-turtlebot-nvidia.sh
```

This starts the same demo through `compose/compose.nvidia.yml` using `technomancer-ros-gazebo-nvidia:jazzy-harmonic` with `gpus: all`.

## Expected Output

The container should print:

```text
Technomancer TurtleBot demo is running.
```

From another terminal, list ROS topics:

```bash
docker compose -f compose/compose.cpu.yml exec turtlebot-demo ros2 topic list
```

Expected topics include:

```text
/clock
/model/tm_turtlebot/cmd_vel
/model/tm_turtlebot/odometry
/scan
```

Publish a short velocity command:

```bash
docker compose -f compose/compose.cpu.yml exec turtlebot-demo \
  ros2 topic pub --once /model/tm_turtlebot/cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.2}, angular: {z: 0.4}}"
```

For the NVIDIA compose file, use `compose/compose.nvidia.yml` in the same commands.

## Stop Containers

```bash
bash scripts/down.sh
```

## Smoke Tests

```bash
bash scripts/test-smoke.sh
```

By default this validates both Docker Compose files, shell syntax, and the demo SDF structure. If the images are already built and you want to run the container-level Gazebo smoke check:

```bash
RUN_CONTAINER_SMOKE=1 bash scripts/test-smoke.sh
```

GitHub Actions runs the lightweight smoke path on pushes and pull requests.

## Troubleshooting ROS Networking

- Keep `network_mode: host` for simple DDS discovery during local demos.
- Keep the same `ROS_DOMAIN_ID` across terminals and containers. This repo defaults to `42`.
- If topics do not appear, restart the ROS daemon inside the container:

```bash
ros2 daemon stop
ros2 daemon start
```

- If discovery is flaky across machines, set `RMW_IMPLEMENTATION=rmw_fastrtps_cpp` consistently or add a DDS profile instead of mixing defaults.
- On WSL2 or Docker Desktop, host networking and GUI forwarding can differ from native Linux. First verify a headless smoke run, then debug display forwarding.

## Existing Images

- `technomancer-ros-base:jazzy`
- `technomancer-ros-dev:jazzy`
- `technomancer-ros-gazebo-cpu:jazzy-harmonic`
- `technomancer-ros-gazebo-nvidia:jazzy-harmonic`
- `technomancer-ros-ai-cpu:jazzy`
- `technomancer-ros-ai-nvidia:jazzy-cuda`
- `technomancer-robot-runtime:jazzy`
