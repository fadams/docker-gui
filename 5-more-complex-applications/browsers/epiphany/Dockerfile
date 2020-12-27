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

# Install Epiphany from testing as older version in stable doesn't
# play YouTube videos and seems to suffer with other glitches.
RUN echo "deb http://ftp.debian.org/debian testing main" \
         > /etc/apt/sources.list.d/stretch-testing.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends -t testing \
    ca-certificates epiphany-browser libpulse0 \
    libgl1-mesa-glx libgl1-mesa-dri gstreamer1.0-libav \
    gstreamer1.0-pulseaudio gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-gl && \
	rm -rf /var/lib/apt/lists/* && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

# Debian seems to have some issues with the default font
# setup. See the following blog:
# http://blog.programster.org/debian-8-gnome-desktop-improve-font-rendering/
COPY fonts.conf /etc/fonts/local.conf

ENTRYPOINT ["epiphany"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t epiphany .
#

