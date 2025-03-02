#!/bin/bash
#

wget https://content.mellanox.com/hpc/hpc-x/v2.22.1rc4/hpcx-v2.22.1-gcc-inbox-ubuntu24.04-cuda12-aarch64.tbz
wget https://developer.download.nvidia.com/compute/nvidia-hpc-benchmarks/redist/nvidia_hpc_benchmarks_openmpi/linux-sbsa/nvidia_hpc_benchmarks_openmpi-linux-sbsa-25.02.04-archive.tar.xz


tar -xjf hpcx-v2.22.1-gcc-inbox-ubuntu24.04-cuda12-aarch64.tbz
tar -xf nvidia_hpc_benchmarks_openmpi-linux-sbsa-25.02.04-archive.tar.xz
