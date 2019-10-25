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

# Install xserver-xspice from testing as it's not in stretch stable.
RUN echo "deb http://ftp.debian.org/debian testing main" > /etc/apt/sources.list.d/stretch-testing.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    pulseaudio ca-certificates locales jwm libgl1-mesa-glx libgl1-mesa-dri \
    spice-vdagent gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
    curl python-numpy python-setuptools && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends -t testing \
    xserver-xspice && \
    # Download websockify and spice-html5.
    WEBSOCKIFY_VERSION=0.9.0 && \
    SPICE_HTML5_VERSION=0.2.2 && \
    curl -sSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    curl -sSL https://github.com/freedesktop/spice-html5/archive/spice-html5-${SPICE_HTML5_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    cd /usr/local/bin/websockify-${WEBSOCKIFY_VERSION} && \
    python setup.py install && \
    mv /usr/local/bin/spice-html5-spice-html5-${SPICE_HTML5_VERSION} /usr/local/bin/spice-html5 && \
    mv /usr/local/bin/spice-html5/spice.html /usr/local/bin/spice-html5/index.html && \
    # Tweak spice-html5 configuration as defaults to the wrong host and port.
    sed -i "s/toggle_console;/toggle_console;\ndocument.getElementById('host').value = window.location.hostname;\ndocument.getElementById('port').value = window.location.port;/g" /usr/local/bin/spice-html5/index.html && \
    #
    # Modify PulseAudio daemon config to support xserver-xspice.
    sed -i "s/; exit-idle-time = 20/exit-idle-time = -1/g" /etc/pulse/daemon.conf && \
    sed -i "s/load-module module-console-kit/#load-module module-console-kit/g" /etc/pulse/default.pa && \
    #
    # Create simple launch script to start pulseaudio, xserver-xspice and the
    # spice vdagent used to support server resizing and copy/paste.
    # Note that the exec before /usr/bin/Xspice is important to ensure that
    # signals get correctly handled - without it the container may hang on exit.
    echo '#!/bin/bash\npulseaudio &\nwebsockify 5800 localhost:5900 --web /usr/local/bin/spice-html5 -D\nexec /usr/bin/Xspice --auto $DISPLAY --password $(cat ${HOME}/.xserver-xspice-passwd) --xsession /usr/local/bin/xsession --vdagent --video-codecs ${SPICE_VIDEO_CODECS:-gstreamer:h264;gstreamer:vp8;gstreamer:mjpeg;spice:mjpeg} --audio-fifo-dir $XDG_RUNTIME_DIR/pulse > /dev/null' > /usr/local/bin/start-server && \
    echo '#!/bin/bash\npacmd load-module module-pipe-sink format=s16 rate=48000 channels=2\njwm' > /usr/local/bin/xsession && \
    chmod +x /usr/local/bin/start-server && \
    chmod +x /usr/local/bin/xsession && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && locale-gen && \ 
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata && \
    # Tidy up JWM for single app use case
    sed -i "s/Desktops width=\"4\"/Desktops width=\"1\"/g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton icon=\"\/usr\/share\/jwm\/jwm-red.svg\">root:1<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton label=\"_\">showdesktop<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<Include>\/etc\/jwm\/debian-menu<\/Include>//g" /etc/jwm/system.jwmrc && \
    #
    # We'll be exporting /tmp/.X11-unix and /run/user as volumes
    # and we need the mode of these to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir /run/user && \
    chmod 1777 /run/user && \
    # Tidy up
    apt-get clean && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix
VOLUME /run/user

CMD ["/usr/local/bin/start-server"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xserver-xspice-html5 .
#

