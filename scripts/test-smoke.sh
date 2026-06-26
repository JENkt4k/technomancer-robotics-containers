#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

docker compose -f compose/compose.cpu.yml config >/dev/null
docker compose -f compose/compose.nvidia.yml config >/dev/null

bash -n scripts/build-all.sh
bash -n scripts/up-turtlebot-cpu.sh
bash -n scripts/up-turtlebot-nvidia.sh
bash -n scripts/down.sh
bash -n demo/turtlebot/run-demo.sh
bash -n demo/turtlebot/smoke.sh

python3 - <<'PY'
import pathlib
import xml.etree.ElementTree as ET

world = pathlib.Path("demo/turtlebot/worlds/turtlebot_demo.sdf")
root = ET.parse(world).getroot()
assert root.tag == "sdf", "world root must be <sdf>"
assert root.find(".//model[@name='tm_turtlebot']") is not None, "missing TurtleBot model"
assert root.find(".//plugin[@name='gz::sim::systems::DiffDrive']") is not None, "missing diff drive plugin"
PY

if [ "${RUN_CONTAINER_SMOKE:-0}" = "1" ]; then
  docker compose -f compose/compose.cpu.yml run --rm --no-deps turtlebot-demo bash /workspace/demo/turtlebot/smoke.sh
fi

echo "Smoke checks passed."
