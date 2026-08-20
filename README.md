# Intel XPU DockerImage

XPU Docker Image for AI use on Ubuntu as base Docker Image. **(For use with Client GPU's)**

Resolves Drivers, APT Packages and some Python requirements.

[Intel-Official-Information](https://www.intel.com/content/www/us/en/developer/articles/tool/pytorch-prerequisites-for-intel-gpu/2-13.html)

## Usage / Important

Mamba Conda and oneAPI are not auto initiated, just run :

- For **Conda**: `source /opt/conda/etc/profile.d/conda.sh`
- For **Mamba**: `source /opt/conda/etc/profile.d/mamba.sh`
- For **oneapi**: `source /opt/intel/oneapi/${ONEAPI_VERSION}/oneapi-vars.sh`

Or if automatically wanted uncomment lines in Dockerfile location is the line `#! For Interactive Mode`.

## Building

**Important for PyTorch Building:**

- **`PyTorch 2.13`** requires **`oneapi 2026.*`**
- **`PyTorch == 2.12.*`** requires **`oneapi 2025.3`**

To **Build** run.

```bash
docker build \
  -t intel-xpu:latest \
  -t intel-xpu:ubuntu-25.10_oneapi-2026.0 \
  .
```

For other oneAPI Versions set **ONEAPI_VERSION** for example:
Tested: [ "2025.3", "2026.0", "2026.1" ]

```bash
export ONEAPI_VERSION="2026.1"
docker build \
  --build-arg ONEAPI_VERSION="${ONEAPI_VERSION}" \
  -t intel-xpu:ubuntu-24.04_oneapi-${ONEAPI_VERSION} \
  .
```

And without the heavy oneAPI toolkit.

```bash
docker build \
  --build-arg ONEAPI_VERSION="NONE" \
  -t intel-xpu:runtime_ubuntu-24.04 \
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

## Example: Docker Usage

Full one for use with Huggingface and it's cache. *(`-w /workspace` is default)*

```bash
#!/usr/bin/env bash

HF_TOKEN=$1

docker run -it \
  --name test-xpu \
  --device /dev/dri \
  --ipc host \
  -e HF_TOKEN=$HF_TOKEN \
  -e HF_HOME="/media/.cache/huggingface" \
  --mount type=bind,src="/path/to/.cache",dst="/media/.cache" \
  --mount type=bind,src="/path/to/Models",dst="/media/Models" \
  --mount type=bind,src="/path/to/project",dst="/workspace" \
  intel-xpu:latest # \
#  bash -c "chmod +x ./src/bin/test.sh; \
#  exec /workspace/src/bin/test.sh"
```

**Conda use** in Scripts or generally for this Docker Image:

```bash
#!/usr/bin/env bash

# Conda Environment
source /opt/conda/etc/profile.d/conda.sh
conda activate ./nixos-conda

cd project # Optional
```

## Example: Building Large Wheels

```bash
export UV_CACHE_DIR="/media/.cache/uv_oneapi-${ONEAPI_VERSION}" # Useful for not building multiple times
export CMAKE_BUILD_PARALLEL_LEVEL=4 # Important for RAM (2-4 GB per Worker)
export MAX_JOBS=4
# Sometimes pytorch is also needed before
uv pip install scikit_build_core # Sometimes needed before, like shown here.
uv build --no-build-isolation --wheel .
```
