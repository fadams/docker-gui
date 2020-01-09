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

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

# nvidia-docker hooks (Only needed for Nvidia Docker V1)
LABEL com.nvidia.volumes.needed=nvidia_driver

RUN sed -i 's/main/main contrib/' \
        /etc/apt/sources.list && \
    mkdir -p /usr/share/man/man1 && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    libreoffice libreoffice-pdfimport \
    libreoffice-ogltrans libreoffice-gtk3 \
    ca-certificates locales tzdata default-jre fonts-noto \
    fonts-symbola fonts-lmodern fonts-freefont-ttf \
    fonts-liberation fonts-dejavu ttf-mscorefonts-installer \
    libpulse0 libgl1-mesa-glx libgl1-mesa-dri && \
    # Tidy up
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && \
    locale-gen && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure tzdata && \
    # Add PulseAudio client config with shm disabled
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

ENTRYPOINT ["libreoffice"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t libreoffice .
#

