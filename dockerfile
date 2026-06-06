FROM ubuntu:25.10

ARG TARGETARCH

#! Basics

# Update APT Repos
RUN apt update -y && apt upgrade -y

# Install Basic Tools
RUN apt install -y software-properties-common gpg wget git


#! Intel ARC

# Add ARC Repository
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics

# Compute Related Packages
RUN apt install -y libze-intel-gpu1 libze1 intel-metrics-discovery intel-opencl-icd clinfo intel-gsc libigc-dev

# Media Related Packages
RUN apt install -y intel-media-va-driver-non-free libmfx-gen1 libvpl2 libvpl-tools libva-glx2 va-driver-all vainfo

# Required for PyTorch
RUN apt install -y libze-dev intel-ocloc

# For RayTracing
RUN apt install -y libze-intel-gpu-raytracing
# intel-level-zero-gpu level-zero


#! Python

# Default Python3
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install -y python3 python3-venv python3-pip

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
#     bash miniconda.sh -b -p /opt/conda && \
#     rm miniconda.sh
# ENV PATH="/opt/conda/bin:$PATH"
# RUN conda init --all

# Install Miniforge
RUN if [ "$TARGETARCH" = "amd64" ]; \
        then MINIFORGE_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; \
        then MINIFORGE_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
        wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${MINIFORGE_ARCH}.sh" -O miniforge.sh && \
        bash miniforge.sh -b -p /opt/conda && \
        rm miniforge.sh

# Clean Temp Files
RUN apt clean && rm -rf /var/lib/apt/lists/*


#! For Interactive Mode

# Conda
ENV PATH="/opt/conda/bin:$PATH"
RUN conda init --all

# Basic
#WORKDIR /workspace
CMD ["/bin/bash"]
