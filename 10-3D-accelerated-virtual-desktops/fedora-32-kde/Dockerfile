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

FROM fedora-kde:32

RUN dnf -y install libvdpau mesa-vdpau-drivers && \
    # Attempt to work out the latest VirtualGL version from
    # https://sourceforge.net/projects/virtualgl/files/
	VGL_VERSION=$(curl -sSL https://sourceforge.net/projects/virtualgl/files/ | grep "<span class=\"name\">[0-9]" | head -n 1 | cut -d \> -f2 | cut -d \< -f1) && \
    echo "VirtualGL version: ${VGL_VERSION}" && \
    # Given the version download and install VirtualGL
    curl -sSL https://sourceforge.net/projects/virtualgl/files/${VGL_VERSION}/VirtualGL-${VGL_VERSION}.x86_64.rpm -o VirtualGL-${VGL_VERSION}.x86_64.rpm && \
    rpm -i VirtualGL-${VGL_VERSION}.x86_64.rpm && \
    rm VirtualGL-${VGL_VERSION}.x86_64.rpm && \
    # Give VGL access to host X Server for 3D rendering
    echo 'XAUTHORITY=$HOME/.Xauthority.docker' > \
         /etc/profile.d/Xauthority-fix.sh && \
    echo 'export LD_PRELOAD=/usr/lib64/libdlfaker.so:/usr/lib64/libvglfaker.so:$LD_PRELOAD' > /etc/profile.d/virtualgl.sh 

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t fedora-kde-vgl:32 .

