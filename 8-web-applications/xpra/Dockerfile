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
    curl cups-client ca-certificates libgl1-mesa-glx libgl1-mesa-dri \
    xvfb xserver-xorg-core x11-xserver-utils gir1.2-gtk-3.0 \
    gir1.2-notify-0.7 libturbojpeg0 liblzo2-dev python-minimal \
    python3 python3-rencode python3-pyinotify python3-pil python3-lz4 \
    python3-dbus python3-cups python3-netifaces python3-gi-cairo \
    python3-brotli python3-gst-1.0 python3-opengl python3-numpy \
    pulseaudio gstreamer1.0-pulseaudio libjs-jquery-ui \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable \
    python3-pip python3-setuptools python3-dev gcc && \
    # Install python packages not available in debian repo via pip.
    # Although crypto and paramiko actually are in debian repo the versions
    # are old and don't seem to work correctly with xpra.
    pip3 --no-cache-dir install wheel && \
    pip3 --no-cache-dir install PyOpenGL-accelerate opencv-python python-lzo \
    cryptography paramiko-ng python-uinput && \
    #
    # Install xpra binary and dependencies. Use xpra releases
    # rather than debian distro as xpra releases is more up to date.
    # Use xserver-xorg-video-dummy from xpra dists to fix DPI issues.
    XPRA_VERSION=3.0-20190927r23994-1 && \
    echo "XPRA_VERSION version: ${XPRA_VERSION}" && \
    curl -sSL https://xpra.org/dists/stretch/main/binary-amd64/ffmpeg-xpra_4.0-1_amd64.deb -o ffmpeg-xpra_4.0-1_amd64.deb && \
    curl -sSL https://xpra.org/dists/stretch/main/binary-amd64/xserver-xorg-video-dummy_0.3.8-5_amd64.deb -o xserver-xorg-video-dummy_0.3.8-5_amd64.deb && \
    curl -sSL https://xpra.org/beta/stretch/main/binary-amd64/python3-xpra_${XPRA_VERSION}_amd64.deb -o python3-xpra_${XPRA_VERSION}_amd64.deb && \
    curl -sSL https://xpra.org/beta/stretch/main/binary-amd64/xpra_${XPRA_VERSION}_amd64.deb -o xpra_${XPRA_VERSION}_amd64.deb && \
    curl -sSL https://xpra.org/beta/stretch/main/binary-amd64/xpra-html5_${XPRA_VERSION}_amd64.deb -o xpra-html5_${XPRA_VERSION}_amd64.deb && \
    dpkg -i ffmpeg-xpra_4.0-1_amd64.deb xserver-xorg-video-dummy_0.3.8-5_amd64.deb && \
    dpkg -i python3-xpra_${XPRA_VERSION}_amd64.deb \
            xpra_${XPRA_VERSION}_amd64.deb \
            xpra-html5_${XPRA_VERSION}_amd64.deb && \
    #
    # In xpra_2.5.3 (and earlier) av-sync capabilities don't seem to be being
    # exchanged correctly. The following is a minimal patch. NB that when
    # updating this Dockerfile to use a later xpra version the code needs to
    # be checked in case a) av-sync capability exchange has been fixed or
    # b) the code has changed such that the patch needs to be tweaked.
    # As it's python the whitespace in the sed statements below is important.
    sed -i 's/    def get_info/    def get_caps(self): return {"av-sync.enabled" : self.av_sync_enabled}\n\n    def get_info/g' /usr/lib/python3/dist-packages/xpra/server/source/avsync_mixin.py && \
    #
    # xpra *really* wants to use a private pulseaudio session, but I *really*
    # want it to use $XDG_RUNTIME_DIR/pulse. There doesn't seem to be a clean
    # way to do this so resorting to patching xpra/server/mixins/audio_server.py
    # This may need changing if the xpra code changes, so it's a bit fragile. 
    sed -i 's/self.pulseaudio_private_dir = osexpand(os.path.join(xpra_rd, "pulse-%s" % display))/self.pulseaudio_private_dir = os.environ.get("XDG_RUNTIME_DIR", "")/g' /usr/lib/python3/dist-packages/xpra/server/mixins/audio_server.py && \
    #
    # Create simple launch scripts to start xpra server and client.
    # Note dbus-launch was made the default in 2.5 and causes issues if D-bus
    # isn't present, so set --dbus-launch= for now. TODO investigate the best
    # way to integrate the xpra server container with a D-bus instance.
    echo '#!/bin/bash\nmkdir -p $XDG_RUNTIME_DIR/pulse\nmkdir -p ~/.xpra\nexec xpra start --daemon=no --notifications=no $DISPLAY --dbus-launch= --html=on $@\n' > /usr/local/bin/start && \
    echo '#!/bin/bash\nxpra attach $@' > /usr/local/bin/attach && \
    chmod +x /usr/local/bin/start && \
    chmod +x /usr/local/bin/attach && \
    # Modify xpra config.
    sed -i "s/log-dir = auto/log-dir = ~\/.xpra/g" /etc/xpra/conf.d/60_server.conf && \
    # Modify PulseAudio daemon config.
    sed -i "s/; exit-idle-time = 20/exit-idle-time = -1/g" /etc/pulse/daemon.conf && \
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
       xpra_${XPRA_VERSION}_amd64.deb \
       xpra-html5_${XPRA_VERSION}_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl python3-pip python3-setuptools python3-dev gcc && \
    apt-get autoremove -y && \
    rm -rf /root/.cache/pip && \
	rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix
VOLUME /run/user

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xpra-html5 .
#
