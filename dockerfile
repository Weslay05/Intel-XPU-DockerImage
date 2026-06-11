FROM ubuntu:25.10

# For Python installation later
ARG TARGETARCH

# Default to `oneapi 2026.0`
ARG ONEAPI_VERSION="2026.0"
ENV ONEAPI_VERSION=${ONEAPI_VERSION}

# APT: Install Basic Packages
RUN apt update -y && apt install -y \
        software-properties-common \
        gnupg dpkg \
        wget curl \
        git \
        ca-certificates


#! APT: Add Repositories

# Intel Graphics Repository
RUN add-apt-repository -y ppa:kobuk-team/intel-graphics && apt update -y

# Intel oneapi Repository
RUN if [ "${ONEAPI_VERSION}" = "NONE" ]; then \
        echo "Skipping oneapi toolkit repository, because ONEAPI_VERSION=${ONEAPI_VERSION}"; \
    else \
        curl -fsSL "https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB" | \
            gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
            tee /etc/apt/sources.list.d/oneAPI.list > /dev/null && \
        apt update -y; \
    fi


#! Install: Build Packages

RUN if [ "${ONEAPI_VERSION}" = "NONE" ]; then \
        echo "Skipping installing cmake, because ONEAPI_VERSION=${ONEAPI_VERSION}"; \
    else \
        echo "Installing cmake because of a oneAPI toolkit version" && \
        apt install -y cmake; \
    fi


#! Install: Intel Drivers

# Compute Related Packages
RUN apt install -y libze-intel-gpu1 libze1 intel-metrics-discovery intel-opencl-icd clinfo intel-gsc libigc-dev
# Media Related Packages
RUN apt install -y intel-media-va-driver-non-free libmfx-gen1 libvpl2 libvpl-tools libva-glx2 va-driver-all vainfo
# Required for PyTorch
RUN apt install -y libze-dev intel-ocloc
# For RayTracing
RUN apt install -y libze-intel-gpu-raytracing


#! Install: Intel oneapi Toolkit

RUN if [ "${ONEAPI_VERSION}" = "NONE" ]; then \
        echo "Skipping oneapi toolkit installation, because ONEAPI_VERSION=${ONEAPI_VERSION}"; \
    elif dpkg --compare-versions "${ONEAPI_VERSION}" ge "2026.0"; then \
        echo "Installing oneapi toolkit: ${ONEAPI_VERSION}" && \
        apt-get install -y intel-oneapi-toolkit-${ONEAPI_VERSION} intel-oneapi-mkl-${ONEAPI_VERSION} intel-deep-learning-essentials-${ONEAPI_VERSION}; \
    elif dpkg --compare-versions "${ONEAPI_VERSION}" ge "2025.0"; then \
        echo "Installing oneapi toolkit: ${ONEAPI_VERSION}" && \
        apt-get install -y intel-basekit intel-oneapi-mkl-${ONEAPI_VERSION} intel-deep-learning-essentials-${ONEAPI_VERSION}; \
    else \
        echo "Installing oneapi toolkit: ${ONEAPI_VERSION}" && \
        apt-get install -y intel-basekit-${ONEAPI_VERSION} intel-oneapi-mkl-${ONEAPI_VERSION} intel-deep-learning-essentials-${ONEAPI_VERSION}; \
    fi

# TODO: Auto installed?
# RUN apt install -y \
#     intel-oneapi-compiler-dpcpp-cpp-2025.3


#! Install: Python

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

#RUN if [ "${ONEAPI_VERSION}" = "NONE" ]; then \
#        echo "Skipping adding oneapi vars to Shell, because ONEAPI_VERSION=${ONEAPI_VERSION}"; \
#    else \
#        echo "source /opt/intel/oneapi/${ONEAPI_VERSION}/oneapi-vars.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null; \
#    fi

#RUN echo "source /opt/conda/etc/profile.d/conda.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null

#RUN echo "source /opt/conda/etc/profile.d/mamba.sh" | tee -a ~/.bashrc ~/.zshrc > /dev/null


#! Basic

WORKDIR /workspace
CMD ["/bin/zsh"]
