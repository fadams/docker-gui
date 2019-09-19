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
    curl ca-certificates libgl1-mesa-glx libgl1-mesa-dri \
    xvfb xserver-xorg-video-dummy x11-xserver-utils gir1.2-gtk-3.0 \
    libturbojpeg0 python-rencode python-paramiko python-pyinotify \
    python-gtkglext1 python-gst-1.0 python-lz4 python-netifaces \
    python-opencv python-dbus python-cryptography python-lzo \
    python-pil python-cups python-pip pulseaudio gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable \
    python-pip python-setuptools python-dev gcc && \
    # Install python packages not available in debian repo via pip.
    # Note that we can't use pip for all python packages as xpra package has
    # dependencies on these and it'd be good to avoid --force-all
    pip install wheel && pip install PyOpenGL-accelerate && \
    # Install xpra binary and dependencies. Use xpra releases
    # rather than debian distro as xpra releases is more up to date.
    XPRA_VERSION=xpra_2.5.3-r23270-1 && \
    echo "XPRA_VERSION version: ${XPRA_VERSION}" && \
    curl -sSL https://xpra.org/dists/stretch/main/binary-amd64/ffmpeg-xpra_4.0-1_amd64.deb -o ffmpeg-xpra_4.0-1_amd64.deb && \
    curl -sSL https://xpra.org/dists/stretch/main/binary-amd64/python2-${XPRA_VERSION}_amd64.deb -o python2-${XPRA_VERSION}_amd64.deb && \
    curl -sSL https://xpra.org/dists/stretch/main/binary-amd64/${XPRA_VERSION}_amd64.deb -o ${XPRA_VERSION}_amd64.deb && \
    dpkg -i ffmpeg-xpra_4.0-1_amd64.deb && \
    dpkg -i python2-${XPRA_VERSION}_amd64.deb ${XPRA_VERSION}_amd64.deb && \
    #
    # In xpra_2.5.3 (and earlier) av-sync capabilities don't seem to be being
    # exchanged correctly. The following is a minimal patch. NB that when
    # updating this Dockerfile to use a later xpra version the code needs to
    # be checked in case a) av-sync capability exchange has been fixed or
    # b) the code has changed such that the patch needs to be tweaked.
    # As it's python the whitespace in the sed statements below is important.
    sed -i 's/updict({}/updict({"av-sync": self.av_sync}/g' /usr/lib/python2.7/dist-packages/xpra/client/mixins/audio.py && \
    sed -i 's/    def get_info/    def get_caps(self): return {"av-sync.enabled" : self.av_sync_enabled}\n\n    def get_info/g' /usr/lib/python2.7/dist-packages/xpra/server/source/avsync_mixin.py && \
    #
    # Create simple launch scripts to start xpra server and client.
    # Note dbus-launch was made the default in 2.5 and causes issues if D-bus
    # isn't present, so set --dbus-launch= for now. TODO investigate the best
    # way to integrate the xpra server container with a D-bus instance. 
    echo '#!/bin/bash\nmkdir -p $XDG_RUNTIME_DIR\nxpra start $DISPLAY --dbus-launch= $@ &\nln -s $XDG_RUNTIME_DIR/xpra/pulse-1/pulse $XDG_RUNTIME_DIR/pulse\nexec sleep infinity' > /usr/local/bin/start && \
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
    rm ffmpeg-xpra_4.0-1_amd64.deb && \
    rm python2-${XPRA_VERSION}_amd64.deb ${XPRA_VERSION}_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl python-pip python-setuptools python-dev gcc && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix
VOLUME /run/user

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xpra .
#

