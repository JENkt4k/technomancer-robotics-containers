#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
docker build -t technomancer-ros-base:jazzy -f docker/Dockerfile.ros-base .
docker build -t technomancer-ros-dev:jazzy --build-arg BASE_IMAGE=technomancer-ros-base:jazzy -f docker/Dockerfile.ros-dev .
docker build -t technomancer-ros-gazebo-cpu:jazzy-harmonic --build-arg BASE_IMAGE=technomancer-ros-dev:jazzy -f docker/Dockerfile.ros-gazebo-cpu .
docker build -t technomancer-ros-gazebo-nvidia:jazzy-harmonic --build-arg BASE_IMAGE=technomancer-ros-dev:jazzy -f docker/Dockerfile.ros-gazebo-nvidia .
docker build -t technomancer-ros-ai-cpu:jazzy --build-arg BASE_IMAGE=technomancer-ros-base:jazzy -f docker/Dockerfile.ros-ai-cpu .
docker build -t technomancer-ros-ai-nvidia:jazzy-cuda -f docker/Dockerfile.ros-ai-nvidia .
