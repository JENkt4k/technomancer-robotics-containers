# Existing upstream images to reuse

| Role | Image | Link |
|---|---|---|
| ROS 2 Jazzy official | `osrf/ros:jazzy-desktop-full` | https://hub.docker.com/r/osrf/ros |
| ROS 2 official library | `ros:jazzy-ros-base` | https://hub.docker.com/_/ros |
| Gazebo official | `gazebo` | https://hub.docker.com/_/gazebo |
| NVIDIA CUDA | `nvidia/cuda:12.6.1-devel-ubuntu24.04` | https://hub.docker.com/r/nvidia/cuda |
| NVIDIA Isaac ROS | NGC Isaac ROS Dev Base | https://catalog.ngc.nvidia.com/orgs/nvidia/teams/isaac/containers/ros |
| Community Gazebo Harmonic + Jazzy | `brean/gz_sim_harmonic:jazzy` | https://github.com/brean/gz-sim-docker |

# New Technomancer images created in this scaffold

- `technomancer-ros-base:jazzy`
- `technomancer-ros-dev:jazzy`
- `technomancer-ros-gazebo-nvidia:jazzy-harmonic`
- `technomancer-ros-ai-nvidia:jazzy-cuda`
- `technomancer-ros-ai-cpu:jazzy`
- `technomancer-robot-runtime:jazzy`
