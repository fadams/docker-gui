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

# Install VirtualGL from the sourceforge downloads page
# https://sourceforge.net/projects/virtualgl/files/
# This attempts to work out the latest version by "scraping" the page,
# but that could fail if the page format changes. If that happens the
# VGL_VERSION variable could simply be set manually below.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used
    apt-get install -y --no-install-recommends \
    curl ca-certificates \
    libgl1-mesa-glx libgl1-mesa-dri \
    libglu1-mesa libxv1 libxtst6 && \
    # Attempt to work out the latest VirtualGL version from
    # https://sourceforge.net/projects/virtualgl/files/
    VGL_VERSION=$(curl -sSL https://sourceforge.net/projects/virtualgl/files/ | grep "<span class=\"name\">[0-9]" | head -n 1 | cut -d \> -f2 | cut -d \< -f1) && \
    echo "VirtualGL version: ${VGL_VERSION}" && \
    # Given the version download and install VirtualGL
    curl -sSL https://sourceforge.net/projects/virtualgl/files/${VGL_VERSION}/virtualgl_${VGL_VERSION}_amd64.deb -o virtualgl_${VGL_VERSION}_amd64.deb && \
    dpkg -i virtualgl_*_amd64.deb && \
    # Tidy up packages only used for installing VirtualGL.
    rm virtualgl_*_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl ca-certificates && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t virtualgl .
#

