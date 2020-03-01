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

# NVIDIA GameWorks Graphics Samples
# https://github.com/NVIDIAGameWorks/GraphicsSamples

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    git ca-certificates build-essential g++ \
    libxinerama-dev libxext-dev libxrandr-dev libxi-dev \
    libxcursor-dev libxxf86vm-dev libvulkan-dev \
    libgl1-mesa-dri libgl1-mesa-dev && \
    cd /usr/src && \
    git clone https://github.com/NVIDIAGameWorks/GraphicsSamples.git && \
    cd GraphicsSamples && \
    # Checkout this version as later versions need Vulkan 1.1,
    # but debian:stretch Vulkan version is 1.0.39.0 so later
    # versions of GameWorks won't compile with stretch and
    # need buster or sid.
    git checkout 61350521f6b183d9f694f5c72c11efcf1a0cc665 -b build && \
    cd samples/build/linux64 && \
    make -j$(getconf _NPROCESSORS_ONLN) release && \
    # Remove packages used for build and installation
    rm -rf build && \
    apt-get clean && \
    apt-get purge -y \
    git ca-certificates build-essential g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/GraphicsSamples/samples/bin/linux64

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t gameworks-graphics-samples-vgl .
#
