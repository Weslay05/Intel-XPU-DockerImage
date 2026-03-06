#! /run/current-system/sw/bin/bash

docker run -it \
  --device /dev/dri \
  -v $(pwd):/workspace \
  -w /workspace
  arc-xpu-env
  
# For conda python
docker run -it \
	--device /dev/dri \
	-e environmentvariable=variable
	-v $(pwd):/workspace \
	-w "/workspace" \
	-p 8188:8188 \
	arc-xpu-env \
	conda run --no-capture-output -p conda \
	python main.py --listen 0.0.0.0;

# Optionally : --group-add $(getent group render | cut -d: -f3)


