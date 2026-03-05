# Ubuntu 25.10 for Battlemage support
FROM ubuntu:25.10

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
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt install -y python3 python3-venv python3-pip
#  Miniconda
RUN mkdir -p ~/miniconda3 \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh \
    && bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 \
    && rm ~/miniconda3/miniconda.sh
ENV PATH="~/miniconda3/bin:$PATH"
RUN ~/miniconda3/bin/conda init

# Clean Temp Files
# RUN apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]