#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

docker build -t technomancer-ros-base:jazzy -f docker/Dockerfile.ros-base .
docker build -t technomancer-ros-dev:jazzy --build-arg BASE_IMAGE=technomancer-ros-base:jazzy -f docker/Dockerfile.ros-dev .
docker compose -f compose/compose.cpu.yml up --build turtlebot-demo
