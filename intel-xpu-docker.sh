#! /run/current-system/sw/bin/bash

docker run -it \
  --device /dev/dri \
  -v $(pwd):/workspace \
  -w /workspace
  arc-xpu-env

# Optionally : --group-add $(getent group render | cut -d: -f3)


