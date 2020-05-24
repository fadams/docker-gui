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

FROM linuxmint-cinnamon-vgl:19.3

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    git autoconf libtool software-properties-common \
    libssl-dev libpam0g-dev nasm xsltproc flex bison \
    pkg-config libcap-dev libpulse-dev libudev-dev \
    intltool libltdl-dev libsndfile-dev bash-completion \
    libsystemd-dev libdbus-1-dev libspeexdsp-dev autopoint \
    libx11-dev xserver-xorg-dev xserver-xorg-core \
    libxfixes-dev libxrandr-dev libxml2-dev dpkg-dev \
    libmp3lame-dev libopus-dev libfdk-aac-dev libjpeg-dev \
    libturbojpeg0-dev libpixman-1-dev libfuse-dev \
    xfonts-base xfonts-75dpi xfonts-100dpi \
    xfonts-scalable xauth && \
    # Clone xrdp and xorgxrdp source from GitHub and build them.
    cd /usr/src && \
    git clone --recursive \
        https://github.com/neutrinolabs/xrdp.git && \
    git clone \
        https://github.com/neutrinolabs/xorgxrdp.git && \
    git clone \
        https://github.com/pulseaudio/pulseaudio.git && \
    git clone \
        https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
    cd xrdp && git checkout v0.9.13 -b build && \
    ./bootstrap && \
    ./configure --enable-opus --enable-fuse --enable-jpeg \
                --enable-tjpeg --enable-ipv6 --enable-vsock \
                --enable-pixman --enable-mp3lame \
                --enable-fdkaac --enable-rdpsndaudin && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    cd ../xorgxrdp && git checkout v0.2.13 -b build && \
    # Hack to make gb layout the default if client fails
    # to send correct keylayout (Vinagre seems to do that).
    # https://github.com/neutrinolabs/xrdp/issues/337
    # Replace pc105 and gb with required model and layout.
    sed -i 's/set.model = g_pc104_str;/set.model = "pc105";/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    sed -i 's/set.layout = g_us_str;/set.layout = "gb";/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    sed -i 's/strlen(client_info->layout)/0/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    ./bootstrap && ./configure && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    sed -i 's/ssl_protocols=TLSv1.2, TLSv1.3/ssl_protocols=TLSv1.2/' \
        /etc/xrdp/xrdp.ini && \
    # The follows lines are needed to allow 3D WM to start
    sed -i 's/readenv=1/readenv=1\nexport XAUTHORITY=$HOME\/.Xauthority.docker/' \
        /etc/xrdp/startwm.sh && \
    sed -i 's/param=-config/param=-ac\nparam=-config/' \
        /etc/xrdp/sesman.ini && \
    # Build xrdp source / sink modules
    cd ../pulseaudio && git checkout v11.1 -b build && \
    ./autogen.sh && \
    cd ../pulseaudio-module-xrdp && \
    git checkout v0.4 -b build && \
    ./bootstrap && \
    ./configure PULSE_DIR=/usr/src/pulseaudio && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    # Modify PulseAudio daemon config to support xrdp.
    echo "load-module module-xrdp-sink" >> \
         /etc/pulse/default.pa && \
    echo "load-module module-xrdp-source" >> \
         /etc/pulse/default.pa && \
    # From systemctl enable xrdp
    ln -snf /lib/systemd/system/xrdp.service \
      /etc/systemd/system/multi-user.target.wants/xrdp.service

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t linuxmint-cinnamon-xrdp:19.3 .

