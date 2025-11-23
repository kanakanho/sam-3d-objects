# SAM 3D Objects Development Environment
# Base image with CUDA 12.1 support
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git \
    vim \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Mambaforge
RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -O /tmp/mambaforge.sh \
    && bash /tmp/mambaforge.sh -b -p /opt/conda \
    && rm /tmp/mambaforge.sh \
    && /opt/conda/bin/conda clean -afy

# Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Copy environment files first for better caching
COPY environments/default.yml /tmp/environments/default.yml
COPY requirements.txt /tmp/requirements.txt
COPY requirements.p3d.txt /tmp/requirements.p3d.txt
COPY requirements.inference.txt /tmp/requirements.inference.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt
COPY pyproject.toml /tmp/pyproject.toml

# Create conda environment from file
RUN mamba env create -f /tmp/environments/default.yml && \
    mamba clean -afy

# Activate environment by default
SHELL ["mamba", "run", "-n", "sam3d-objects", "/bin/bash", "-c"]

# Set environment variables for pip
ENV PIP_EXTRA_INDEX_URL="https://pypi.ngc.nvidia.com https://download.pytorch.org/whl/cu121"
ENV PIP_FIND_LINKS="https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.5.1_cu121.html"

# Copy the rest of the project
COPY . /workspace

# Install sam3d-objects package and dependencies
RUN mamba run -n sam3d-objects pip install -e '.[dev]' && \
    mamba run -n sam3d-objects pip install -e '.[p3d]' && \
    mamba run -n sam3d-objects pip install -e '.[inference]'

# Apply patches
RUN cd /workspace/patching && ./hydra || true

# Set the default command to activate the environment
CMD ["mamba", "run", "--no-capture-output", "-n", "sam3d-objects", "/bin/bash"]
