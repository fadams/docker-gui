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

FROM debian:stretch-slim

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
    cuda-cudart-${CUDA_VERSION} && \
    ln -s cuda-${CUDA_VERSION} /usr/local/cuda && \
    # Remove packages used for installation
    apt-get clean && \
    apt-get purge -y apt-transport-https wget gnupg \
            ca-certificates && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["nvidia-smi"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t nvidia-smi .


