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
# This uses VirtualGL to perform “split rendering” (GLX forking) which
# intercepts GLX calls and renders to a memory buffer, which can then be 
# forwarded to a remote display.

# Use our virtualgl base image
FROM virtualgl

ENV CUDA_VERSION 9.0
ENV NVIDIA_REQUIRE_CUDA "cuda>=${CUDA_VERSION}"
ENV CUDA_FULL_VERSION ${CUDA_VERSION}.176

# nvidia-docker hooks (Only needed for Nvidia Docker V1)
LABEL com.nvidia.volumes.needed=nvidia_driver
LABEL com.nvidia.cuda.version="${CUDA_FULL_VERSION}"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used to install CUDA
    apt-get install -y --no-install-recommends \
    apt-transport-https wget gnupg ca-certificates && \
    # Add the CUDA packages and signing key
	wget -O /usr/share/keyrings/cuda-archive.key https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/3bf863cc.pub && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cuda-archive.key] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libgl1-mesa-dri libglu1-mesa freeglut3 \
    cuda-cudart-${CUDA_VERSION} \
    cuda-samples-${CUDA_VERSION} && \
    ln -s cuda-${CUDA_VERSION} /usr/local/cuda && \
    # Compile the smokeParticles sample. Note the tweak of findgllib.mk
    # that is needed to find the OpenGL libraries on debian.
    cd /usr/local/cuda/samples/5_Simulations && \
    cd smokeParticles && \
    sed -i 's/grep -i ubuntu/grep -i "ubuntu\\|debian"/' \
        findgllib.mk && \
    make && cp smokeParticles /usr/local/cuda/bin/. && \
    cp -R data /usr/local/cuda/bin/. && make clean && \
    # Remove the packages used for installation and build
    apt-get clean && \
    apt-get purge -y apt-transport-https wget gnupg \
            ca-certificates cuda-samples-${CUDA_VERSION} && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set WORKDIR and use relative path as this example uses Nvidia's
# sdkFindFilePath to find the data directory and using the absolute
# path doesn't work correctly.
WORKDIR /usr/local/cuda/bin

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t cuda-smoke-vgl .


