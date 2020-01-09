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

# nvidia-docker hooks (Only needed for Nvidia Docker V1)
LABEL com.nvidia.volumes.needed=nvidia_driver

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages
    apt-get install -y --no-install-recommends \
    ocl-icd-libopencl1 ocl-icd-opencl-dev clinfo tar \
    libxmu-dev freeglut3-dev libglew-dev libgl1-mesa-glx \
    libgl1-mesa-dri wget ca-certificates gcc g++ make && \
    # Add the Nvidia OpenCL Installable Client Driver
    mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > \
         /etc/OpenCL/vendors/nvidia.icd && \
    # Download the Nvidia SDK which includes the OpenCL samples.
    # Note that the samples listed at https://developer.nvidia.com/opencl
    # are incomplete, missing the "shared" and "common" code needed to
    # compile! We therefore pull the 4.2.9 SDK here, because that is the
    # last version to include the full compilable OpenCL source tree.
    cd /usr/local/src && \
    wget -O gpucomputingsdk_4.2.9_linux.run "https://developer.download.nvidia.com/compute/cuda/4_2/rel/sdk/gpucomputingsdk_4.2.9_linux.run" && \
    chmod +x gpucomputingsdk_4.2.9_linux.run && \
    ./gpucomputingsdk_4.2.9_linux.run --tar xfp && \
    rm gpucomputingsdk_4.2.9_linux.run && \
    rm install-sdk-linux.pl && \
    mv sdk/OpenCL sdk/shared . && \
    rm -rf sdk && rm -rf shared/lib/linux && \
    sed -i 's/GLEW_x86_64/GLEW/' \
        /usr/local/src/OpenCL/common/common_opencl.mk && \
    sed -i 's/-Wimplicit//' \
        /usr/local/src/OpenCL/common/common_opencl.mk && \
    # Fix issue with oclNbodyKernel.cl
    sed -i 's/mul24(get_local_size(0), get_local_id(1))/mul24((uint)get_local_size(0), get_local_id(1))/' /usr/local/src/OpenCL/src/oclNbody/oclNbodyKernel.cl && \
    # Fix issue with SobelFilter.cl (Not used here, but fixed for info)
    sed -i 's/mul24(get_local_size(1), get_global_size(0))/mul24((uint)get_local_size(1), get_global_size(0))/' /usr/local/src/OpenCL/src/oclSobelFilter/SobelFilter.cl && \
    sed -i 's/mul24((get_group_id(0) + 1)/mul24((uint)(get_group_id(0) + 1)/' /usr/local/src/OpenCL/src/oclSobelFilter/SobelFilter.cl && \
    sed -i 's/mul24(get_group_id(0)/mul24((uint)get_group_id(0)/' /usr/local/src/OpenCL/src/oclSobelFilter/SobelFilter.cl && \
    cd OpenCL && \
    mv src/oclNbody . && rm -rf src/* && mv oclNbody src/. && \
    make && \
    chmod 777 /usr/local/bin && \
    mkdir -p /usr/local/bin/src && \
    cp /usr/local/src/OpenCL/bin/linux/release/oclNbody \
       /usr/local/bin/. && \
    cp /usr/local/src/OpenCL/src/oclNbody/*.cl \
       /usr/local/bin/src/. && \
    # Remove packages used for installation
    rm -rf /usr/local/src/* && \
    apt-get clean && \
    apt-get purge -y wget ca-certificates gcc g++ make && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

# Set WORKDIR and use relative path as this example uses Nvidia's
# shrFindFilePath to find the kernel directory and using the absolute
# path doesn't work correctly.
WORKDIR /usr/local/bin/
ENTRYPOINT ["oclNbody"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t opencl-nbody .


