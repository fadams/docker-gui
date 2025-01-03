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

#FROM debian:stretch-slim # Deprecated
FROM ubuntu:24.04

# Install Chromium
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
	wget bzip2 unzip ca-certificates gnupg dirmngr procps \
    fonts-symbola fonts-lmodern fonts-freefont-ttf \
    fonts-liberation fonts-dejavu gsfonts librsvg2-common \
    libgtk-3-0 libgtk2.0-0 libnss3 libxt6 libxtst6 libavcodec-extra60 \
    libpci3 libvpx9 libdbus-glib-1-2 libcanberra-gtk3-module \
    # No libgl1-mesa-glx in ubuntu:24.04, explicitly install libglx-mesa0 libgl1
    libpulse0 libv4l-0 libglx-mesa0 libgl1 libgl1-mesa-dri \
    libegl1 libgles2 libvdpau1 && \
    # Ubuntu Chromium uses snap, so download and install latest Chromium.
    LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"  && \
    REVISION=$(wget -qO - $LASTCHANGE_URL) && \
    echo "Latest revision is $REVISION" && \
    ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media" && \
    ZIP_FILE="${REVISION}-chrome-linux.zip" && \
    cd /usr/lib && \
    wget -O $ZIP_FILE $ZIP_URL && \
    unzip $ZIP_FILE && rm $ZIP_FILE &&\
	rm -rf /var/lib/apt/lists/* && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

# Debian seems to have some issues with the default font setup.
# See the following blog:
# http://blog.programster.org/debian-8-gnome-desktop-improve-font-rendering/
COPY fonts.conf /etc/fonts/local.conf

ENTRYPOINT ["/usr/lib/chrome-linux/chrome"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t chromium .
#

