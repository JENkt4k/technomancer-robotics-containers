#!/usr/bin/env bash
set -eo pipefail

source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
set -u

WORLD="${TURTLEBOT_WORLD:-/workspace/demo/turtlebot/worlds/turtlebot_demo.sdf}"
test -f "$WORLD"

ros2 --help >/dev/null
gz sim --versions >/dev/null
gz sdf -k "$WORLD"

timeout "${SMOKE_TIMEOUT:-12}" bash -lc "gz sim -r -s '$WORLD' >/tmp/tm-gz-smoke.log 2>&1" || status=$?
status="${status:-0}"
if [ "$status" != "0" ] && [ "$status" != "124" ]; then
  cat /tmp/tm-gz-smoke.log >&2 || true
  exit "$status"
fi

echo "TurtleBot smoke test passed."
