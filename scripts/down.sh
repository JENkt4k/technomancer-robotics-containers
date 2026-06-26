#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

docker compose -f compose/compose.cpu.yml down --remove-orphans
docker compose -f compose/compose.nvidia.yml down --remove-orphans
