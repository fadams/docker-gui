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

# Install remmina and all plugins
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            -t stretch-backports \
    remmina remmina-plugin-vnc remmina-plugin-rdp \
    remmina-plugin-nx remmina-plugin-spice \
    remmina-plugin-exec remmina-plugin-xdmcp \
    remmina-plugin-secret remmina-plugin-telepathy \
    libvdpau1 mesa-vdpau-drivers \
    libgl1-mesa-glx libgl1-mesa-dri && \
    rm -rf /var/lib/apt/lists/* && \
    # remmina-plugin-rdp and remmina-plugin-spice
    # have a PulseAudio dependency, so enable PulseAudio for those.
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
       /etc/pulse/client-noshm.conf

ENTRYPOINT ["remmina"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t remmina .
#

