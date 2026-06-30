# Technomancer Robotics Containers

Container scaffold for ROS 2 Jazzy, Gazebo Harmonic, NVIDIA GPU passthrough, CPU AI nodes, and robot runtime deployment.

The first working demo is a small TurtleBot-style differential-drive robot in Gazebo Harmonic with ROS 2 Jazzy bridge topics for `/clock`, `/scan`, odometry, and velocity commands.

## Prerequisites

- Docker Engine with the Docker Compose v2 plugin.
- A Linux host, Windows or macOS with Docker Desktop, or a WSL2 distro
  capable of running Linux containers.
- An X11 server is required only if you want to display the Gazebo GUI from
  inside the container. See [Gazebo display modes](#gazebo-display-modes).
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
bash scripts/up-turtlebot-nvidia.sh
```

This starts the same demo through `compose/compose.nvidia.yml` using `technomancer-ros-gazebo-nvidia:jazzy-harmonic` with `gpus: all`.

## Expected Output

The container should print:

```text
Technomancer TurtleBot demo is running.
```

## Gazebo Display Modes

### Headless mode (default)

The demo starts Gazebo with `gz sim -r -s`: `-r` starts simulation
immediately and `-s` runs only the simulation server. No window is expected.
This mode works on CI and hosts without a desktop or X server.

You can control and inspect the headless simulation through ROS topics. For
example:

```bash
docker compose -f compose/compose.cpu.yml exec turtlebot-demo \
  bash demo/turtlebot/ros2.sh topic list
```

### Graphical mode

Keep the headless demo running, then start the Gazebo graphical client from a
second terminal. The client connects to the existing simulation server. Host
setup differs because Linux GUI applications inside the container need access
to a display server.

#### Linux with X11

Allow local containers to connect to X11:

```bash
xhost +local:root
```

Start the client:

```bash
docker compose -f compose/compose.cpu.yml exec \
  -e DISPLAY="$DISPLAY" \
  turtlebot-demo bash demo/turtlebot/gz.sh sim -g
```

Revoke the additional X11 permission when finished:

```bash
xhost -local:root
```

If the client reports an OpenGL or rendering error, force software rendering:

```bash
docker compose -f compose/compose.cpu.yml exec \
  -e DISPLAY="$DISPLAY" \
  -e LIBGL_ALWAYS_SOFTWARE=1 \
  turtlebot-demo bash demo/turtlebot/gz.sh sim -g
```

#### Windows with Docker Desktop

Windows does not include an X11 server. Install and start one such as VcXsrv
or X410. Configure it to accept TCP connections, allow it through Windows
Firewall on private networks, and keep it running while using Gazebo.

For VcXsrv, a typical XLaunch configuration is **Multiple windows**, **Start
no client**, and **Disable access control**. Disabling access control is
convenient for local development but allows other reachable clients to use the
display, so use it only on a trusted network.

Start the Gazebo client from PowerShell or Git Bash:

```bash
docker compose -f compose/compose.cpu.yml exec \
  -e DISPLAY=host.docker.internal:0.0 \
  -e LIBGL_ALWAYS_SOFTWARE=1 \
  turtlebot-demo bash demo/turtlebot/gz.sh sim -g
```

`host.docker.internal` routes from the Linux container back to the Windows
host where the X server is running. WSLg does not automatically provide a
display to Docker Desktop containers; use the X-server approach above unless
you explicitly mount and configure the WSLg sockets.

#### macOS with Docker Desktop

Install and start XQuartz. In **XQuartz Settings > Security**, enable
**Allow connections from network clients**, then restart XQuartz. In an
XQuartz terminal, allow connections from the local host:

```bash
xhost +localhost
```

Start the Gazebo client:

```bash
docker compose -f compose/compose.cpu.yml exec \
  -e DISPLAY=host.docker.internal:0 \
  -e LIBGL_ALWAYS_SOFTWARE=1 \
  turtlebot-demo bash demo/turtlebot/gz.sh sim -g
```

Revoke the X11 permission when finished:

```bash
xhost -localhost
```

If macOS cannot connect on display `:0`, verify that XQuartz is running and
accepting network clients. Some XQuartz versions also require TCP listening to
be enabled before restarting the application.

For the NVIDIA Compose file, replace `compose/compose.cpu.yml` with
`compose/compose.nvidia.yml` in the commands above.

### GUI troubleshooting

- `could not connect to display`: confirm the host X server is running,
  `DISPLAY` is correct, and the firewall permits the connection.
- `Authorization required`: grant X11 access using the host-specific steps
  above.
- OpenGL, EGL, or Ogre errors: retry with
  `LIBGL_ALWAYS_SOFTWARE=1`.
- An empty client or no world: confirm the headless `turtlebot-demo` service
  is still running before starting `gz sim -g`.
- Git Bash rewriting `/workspace` to `C:/Program Files/Git/workspace`: use
  the relative paths shown in this README.

From another terminal, list ROS topics:

```bash
docker compose -f compose/compose.cpu.yml exec turtlebot-demo \
  bash demo/turtlebot/ros2.sh topic list
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
  bash demo/turtlebot/ros2.sh topic pub --once \
  model/tm_turtlebot/cmd_vel geometry_msgs/msg/Twist \
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
