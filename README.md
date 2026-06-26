# Technomancer Robotics Containers

Container scaffold for ROS 2 Jazzy, Gazebo Harmonic, NVIDIA GPU passthrough, CPU AI nodes, and robot runtime deployment.

## Build

```bash
./scripts/build-all.sh
```

## Run NVIDIA stack

```bash
xhost +local:root
docker compose -f compose/compose.nvidia.yml run --rm gazebo bash
```

## Run CPU stack

```bash
docker compose -f compose/compose.cpu.yml run --rm ai-cpu bash
```

## Test GPU inside NVIDIA containers

```bash
nvidia-smi
python3 - <<'PY'
import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'no cuda')
PY
```

## Notes

- Use host networking for ROS 2 DDS discovery unless you standardize DDS config.
- Use NVIDIA Container Toolkit on the host for GPU passthrough.
- The runtime image expects a built ROS workspace copied into `./install` at build time.
