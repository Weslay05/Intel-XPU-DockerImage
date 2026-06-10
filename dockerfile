FROM ubuntu:25.10

#! Basic

# For Python installation later
ARG TARGETARCH 

# APT: Install Basic Packages
RUN apt update -y && apt install -y \
        software-properties-common \
        gnupg \
        wget curl \
        git \
        ca-certificates


#! APT: Package Archives

# Add Intel Graphics Repository
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics && apt update -y

# Add Intel oneapi Repository
RUN curl -fsSL "https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB" | \
        gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
        tee /etc/apt/sources.list.d/oneAPI.list > /dev/null && \
    apt update -y


#! APT: Install Packages

# Useful
RUN apt install -y cmake

# Intel oneapi toolkit
RUN apt install -y intel-basekit intel-oneapi-toolkit

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
# RUN if [ "$TARGETARCH" = "amd64" ]; \
#         then MINIFORGE_ARCH="x86_64"; \
#     elif [ "$TARGETARCH" = "arm64" ]; \
#         then MINIFORGE_ARCH="aarch64"; \
#     else \
#         echo "Unsupported architecture: $TARGETARCH" && exit 1; \
#     fi && \
#         curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${MINIFORGE_ARCH}.sh" -o miniconda.sh && \
#         bash miniconda.sh -b -p /opt/conda && \
#         rm miniconda.sh

# Install Miniforge
ENV MAMBA_ROOT_PREFIX=/opt/conda
RUN if [ "$TARGETARCH" = "amd64" ]; \
        then MINIFORGE_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; \
        then MINIFORGE_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
        curl -fsSL "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${MINIFORGE_ARCH}.sh" -o miniforge.sh && \
        sh miniforge.sh -b -p /opt/conda && \
        rm miniforge.sh


#! For Interactive Mode

# Install zsh & oh-my-zsh
RUN apt -y install zsh && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
ENV SHELL=/bin/zsh

RUN echo "source /opt/intel/oneapi/setvars.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null
#RUN echo "source /opt/conda/etc/profile.d/conda.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null
#RUN echo "source /opt/conda/etc/profile.d/mamba.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null


#! Basic

WORKDIR /workspace
CMD ["/bin/zsh"]
