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

# Install xpra and xserver-xorg-video-dummy
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl xvfb cups-client libgl1-mesa-glx libgl1-mesa-dri \
    xserver-xorg-core x11-xserver-utils gir1.2-gtk-3.0 \
    gir1.2-notify-0.7 libturbojpeg0 liblzo2-dev \
    cmake make gcc g++ \
    python-minimal python3 python3-rencode \
    python3-pyinotify python3-pil python3-lz4 \
    python3-dbus python3-cups python3-netifaces \
    python3-gi-cairo python3-brotli python3-gst-1.0 \
    python3-opengl python3-numpy ca-certificates \
    pulseaudio gstreamer1.0-pulseaudio xfonts-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    xfonts-75dpi xfonts-100dpi xfonts-scalable \
    python3-pip python3-setuptools python3-dev && \
    # Install python packages not available in debian repo via
    # pip. Although crypto and paramiko are in debian repo the
    # versions are old and don't work correctly with xpra.
    pip3 --no-cache-dir install wheel scikit-build && \
    pip3 --no-cache-dir install PyOpenGL-accelerate==3.1.0 \
    opencv-python python-lzo cryptography paramiko-ng \
    python-uinput && \
    #
    # Install xpra binary and dependencies. Use xpra releases
    # rather than debian distro as xpra releases is more
    # up to date. Use xserver-xorg-video-dummy from xpra
    # dists to fix DPI issues.
    XPRA_VERSION=3.0.5-r24939-1 && \
    XPRA=https://xpra.org/dists/stretch/main/binary-amd64 && \
    echo "XPRA_VERSION version: ${XPRA_VERSION}" && \
    curl -sSL ${XPRA}/ffmpeg-xpra_4.0-1_amd64.deb \
         -o ffmpeg-xpra_4.0-1_amd64.deb && \
    curl -sSL \
         ${XPRA}/xserver-xorg-video-dummy_0.3.8-5_amd64.deb \
         -o xserver-xorg-video-dummy_0.3.8-5_amd64.deb && \
    curl -sSL ${XPRA}/python3-xpra_${XPRA_VERSION}_amd64.deb \
         -o python3-xpra_${XPRA_VERSION}_amd64.deb && \
    curl -sSL ${XPRA}/xpra_${XPRA_VERSION}_amd64.deb \
         -o xpra_${XPRA_VERSION}_amd64.deb && \
    dpkg -i ffmpeg-xpra_4.0-1_amd64.deb \
         xserver-xorg-video-dummy_0.3.8-5_amd64.deb && \
    dpkg -i python3-xpra_${XPRA_VERSION}_amd64.deb \
         xpra_${XPRA_VERSION}_amd64.deb && \
    #
    # xpra *really* wants to use a private pulseaudio
    # session, but I *really* want it to use
    # $XDG_RUNTIME_DIR/pulse. There doesn't seem to be a
    # clean way to do this so resorting to patching
    # xpra/server/mixins/audio_server.py This may need
    # changing if the xpra code changes, so it's a bit fragile. 
    sed -i 's/self.pulseaudio_private_dir = osexpand(os.path.join(xpra_rd, "pulse-%s" % display))/self.pulseaudio_private_dir = os.environ.get("XDG_RUNTIME_DIR", "")/g' /usr/lib/python3/dist-packages/xpra/server/mixins/audio_server.py && \
    #
    # Create simple launch scripts to start xpra server
    # and client. Note dbus-launch was made the default in
    # 2.5 and causes issues if D-bus isn't present, so set
    # --dbus-launch= for now. TODO investigate the best way
    # to integrate the xpra server container with D-bus.
    echo '#!/bin/bash\nmkdir -p $XDG_RUNTIME_DIR/pulse\nmkdir -p ~/.xpra\nexec xpra start --daemon=no --notifications=no $DISPLAY --dbus-launch= $@\n' > /usr/local/bin/start && \
    echo '#!/bin/bash\nxpra attach $@' > \
         /usr/local/bin/attach && \
    chmod +x /usr/local/bin/start && \
    chmod +x /usr/local/bin/attach && \
    # Modify xpra config.
    sed -i "s/log-dir = auto/log-dir = ~\/.xpra/g" \
        /etc/xpra/conf.d/60_server.conf && \
    # Modify PulseAudio daemon config.
    sed -i "s/; exit-idle-time = 20/exit-idle-time = -1/g" \
        /etc/pulse/daemon.conf && \
    sed -i "s/load-module module-console-kit/#load-module module-console-kit/g" /etc/pulse/default.pa && \
    # We'll be exporting /tmp/.X11-unix and /run/user as volumes
    # and we need the mode of these to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir /run/user && \
    chmod 1777 /run/user && \
    # Tidy up
    rm ffmpeg-xpra_4.0-1_amd64.deb \
       xserver-xorg-video-dummy_0.3.8-5_amd64.deb \
       python3-xpra_${XPRA_VERSION}_amd64.deb \
       xpra_${XPRA_VERSION}_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl python3-pip python3-setuptools \
            python3-dev cmake make gcc g++ && \
    apt-get autoremove -y && \
    rm -rf /root/.cache/pip && \
    rm -rf /var/lib/apt/lists/* && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
       /etc/pulse/client-noshm.conf

VOLUME /tmp/.X11-unix
VOLUME /run/user

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xpra .
#

