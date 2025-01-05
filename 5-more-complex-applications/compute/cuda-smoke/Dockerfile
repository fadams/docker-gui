#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

FROM ubuntu:24.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used to install CUDA
    apt-get install -y --no-install-recommends \
    apt-transport-https wget gnupg git make ca-certificates && \
    # Install CUDA packages via the new cuda-keyring package as per:
    # https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#network-repo-installation-for-ubuntu
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && rm cuda-keyring_1.1-1_all.deb && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    # No libgl1-mesa-glx in ubuntu:24.04, explicitly install libglx-mesa0 libgl1
    libglx-mesa0 libgl1 libgl1-mesa-dri libglu1-mesa-dev freeglut3-dev \
    # Install cuda runtime and nvcc
    cuda-cudart-12-6 cuda-nvcc-12-6 && \
    # Install cuda-samples from git repo
    cd /usr/local && \
    git clone https://github.com/NVIDIA/cuda-samples.git && \
    cd cuda-samples && git checkout v12.5 -b build && \
    # Compile the smokeParticles sample.
    cd /usr/local/cuda-samples/Samples/5_Domain_Specific/smokeParticles && \
    make && cp smokeParticles /usr/local/cuda/bin/. && \
    cp -R data /usr/local/cuda/bin/. && make clean && \
    # Remove cuda-samples source code after compilation
    rm -rf /usr/local/cuda-samples && \
    # Remove the packages used for installation and build
    apt-get clean && \
    apt-get purge -y apt-transport-https wget gnupg git make \
            ca-certificates cuda-nvcc-12-6 && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set WORKDIR and use relative path as this example uses Nvidia's
# sdkFindFilePath to find the data directory and using the absolute
# path doesn't work correctly.
WORKDIR /usr/local/cuda/bin
ENTRYPOINT ["./smokeParticles"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t cuda-smoke .


