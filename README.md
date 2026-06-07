# Intel XPU DockerImage

XPU Docker Image for AI use on Ubuntu as base Docker Image. **(For use with Client GPU's)**

Resolves Drivers, APT Packages and some Python requirements.

[Intel-Official-Information](https://www.intel.com/content/www/us/en/developer/articles/tool/pytorch-prerequisites-for-intel-gpu/2-13.html)

To **Build** run

```bash
docker build \
  -t xpu-ai-env:latest \
  -t xpu-ai-env:25.10 \
  .
```

## Docker Arguments

### Docker with Scripts

Example for use with **changing commands** or just **scripts**.

```bash
bash -c "chmod +x ./src/bin/test.sh; \
exec /workspace/src/bin/test.sh"
```

### Permissions (Important)

For **Device Drivers**

`--device /dev/dri` # Only GPU
`--privileged` # All Drivers

Inter process **memory Communication**

`--shm-size 4g` # Limited
`--ipc host` # Raw Memory access

*Optionally* : `--group-add $(getent group render | cut -d: -f3)`

### Basics

Networking : `--network ["bridge", "host", "..."]`

Volumes & mounting/binding *(See [Docker-Docs](https://docs.docker.com/engine/storage/bind-mounts/) for more Info)*

- `-v path-or-volume:mount-point` # Volume or Disk as Volume bind
- `--mount type=bind,src="/path/to/source",dst="/path/to/destination"` # Normal disk to container bind

Specific working directory : `-w working-dir`

## Docker command example

**Conda use** in Scripts or generally for this Docker Image:

```bash
#!/usr/bin/env bash

# Conda Environment
source /opt/conda/etc/profile.d/conda.sh
conda activate ./nixos-conda

cd project # Optional
```

Full one for use with Huggingface and it's cache.

```bash
#!/usr/bin/env bash
HF_TOKEN=$1

docker run -it \
  --name test-xpu \
  --device /dev/dri \
  --ipc host \
  -e HF_TOKEN=$HF_TOKEN \
  -e HF_HOME="/path/to/cache" \
  --mount type=bind,src="/path/to/.cache/huggingface",dst="/media/.cache/huggingface" \
  --mount type=bind,src="/path/to/Models",dst="/media/Models" \
  --mount type=bind,src="/path/to/project",dst="/workspace" \
  -w /workspace \
  xpu-ai-env:latest # \
#  bash -c "chmod +x ./src/bin/test.sh; \
#  exec /workspace/src/bin/test.sh"
```
