#!/usr/bin/env bash
set -eo pipefail

source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
set -u

WORLD="${TURTLEBOT_WORLD:-/workspace/demo/turtlebot/worlds/turtlebot_demo.sdf}"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-42}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}"
export GZ_SIM_RESOURCE_PATH="/workspace/demo/turtlebot:${GZ_SIM_RESOURCE_PATH:-}"

cleanup() {
  jobs -pr | xargs -r kill
}
trap cleanup EXIT INT TERM

gz sim -r -s "$WORLD" &
GZ_PID=$!

sleep 4

ros2 run ros_gz_bridge parameter_bridge \
  /clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock \
  /scan@sensor_msgs/msg/LaserScan[gz.msgs.LaserScan \
  /model/tm_turtlebot/odometry@nav_msgs/msg/Odometry[gz.msgs.Odometry \
  /model/tm_turtlebot/cmd_vel@geometry_msgs/msg/Twist]gz.msgs.Twist &
BRIDGE_PID=$!

cat <<'MSG'
Technomancer TurtleBot demo is running.

Useful commands from another terminal:
  docker compose -f compose/compose.cpu.yml exec turtlebot-demo bash demo/turtlebot/ros2.sh topic list
  docker compose -f compose/compose.cpu.yml exec turtlebot-demo bash demo/turtlebot/ros2.sh topic pub --once model/tm_turtlebot/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.2}, angular: {z: 0.4}}"
MSG

wait "$GZ_PID" "$BRIDGE_PID"
