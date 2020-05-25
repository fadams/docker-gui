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

FROM ubuntu-gnome-vgl:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    python-numpy python-setuptools \
    xserver-xspice-hwe-18.04 spice-vdagent && \
    # LightDM complains if Xvnc isn't present, even if
    # [VNCServer] config. specifies a command= option.
    ln -snf /usr/bin/Xspice /usr/bin/Xvnc && \
    mkdir /tmp/audio-fifo && \
    chmod 1777 /tmp/audio-fifo && \
    # Modify PulseAudio daemon config to support SPICE.
    echo "load-module module-pipe-sink file=/tmp/audio-fifo/playback.fifo format=s16 rate=48000 channels=2" >> /etc/pulse/default.pa && \
    # The Xspice --auto option is convenient, but if
    # we have large display resolutions Xspice will
    # crash with OOM. We need to modify the config in
    # /etc/X11/spiceqxl.xorg.conf, which in turn means
    # we can't use --auto and that exposes a bug in
    # /usr/bin/Xspice where temp_dir isn't initialised.
    sed -i 's/if args.auto:/temp_dir = ""\nif args.auto:/' /usr/bin/Xspice && \
    # Set buffers to handle larger resolutions.
    sed -i 's/#Option "NumHeads" "4"/Option "NumHeads" "1"/' /etc/X11/spiceqxl.xorg.conf && \
    sed -i 's/#Option "SurfaceBufferSize" "128"/Option "SurfaceBufferSize" "512"/' /etc/X11/spiceqxl.xorg.conf && \
    sed -i 's/#Option "CommandBufferSize" "128"/Option "CommandBufferSize" "512"/' /etc/X11/spiceqxl.xorg.conf && \
    sed -i 's/#Option "FrameBufferSize" "16"/Option "FrameBufferSize" "32"/' /etc/X11/spiceqxl.xorg.conf && \
    # If not using --auto the --audio-fifo-dir flag
    # seems to be ignored, so we need to use the config.
    sed -i 's/#Option "SpicePlaybackFIFODir" "\/tmp\/"/Option "SpicePlaybackFIFODir" "\/tmp\/audio-fifo"/' /etc/X11/spiceqxl.xorg.conf && \
    # Download websockify and flexVDI fork of
    # eyeos spice-web-client.
    WS_VERSION=0.9.0 && \
    SPICE=3.1.0 && \
    curl -sSL https://github.com/novnc/websockify/archive/v${WS_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    curl -sSL https://github.com/flexVDI/spice-web-client/archive/${SPICE}.tar.gz | tar -xzv -C /usr/local/bin && \
    cd /usr/local/bin/websockify-${WS_VERSION} && \
    python setup.py install && \
    mv /usr/local/bin/spice-web-client-${SPICE} \
       /usr/local/bin/spice-web-client && \
    # Tweak spice-web-client to add a basic
    # host/port/password entry UI.
    sed -i 's/document.location.port/port/g' \
        /usr/local/bin/spice-web-client/lib/utils.js && \
    sed -i 's/<div class="float-right">/<div class="float-right">\n\n                <label for="host">Host: <\/label><input type="text" id="host" value=""\/><label for="port"> Port: <\/label><input type="text" id="port" value=""\/><label for="password"> Password: <\/label><input type="password" id="password" value="" onkeyup="checkIfEnterPressed(event)"\/>\n/g' /usr/local/bin/spice-web-client/index.html && \
    sed -i 's/$(document).ready(start);/$(document).ready(init);/g' /usr/local/bin/spice-web-client/run.js && \
    sed -i 's/translate();//g' \
        /usr/local/bin/spice-web-client/run.js && \
    sed -i 's/function start ()/\nfunction init () {\n	translate();\n    document.getElementById("showclientid").style.display = "none";\n    document.getElementById("uploadfile").style.display = "none";\n    document.getElementById("host").value = document.location.hostname;\n    document.getElementById("port").value = document.location.port;\n}\n\nfunction checkIfEnterPressed (event) {\n    if (event.keyCode === 13) {\n        start();\n    }\n}\nfunction start ()/g' /usr/local/bin/spice-web-client/run.js && \
    sed -i "s/data\['spice_address'\] || ''/document.getElementById('host').value/g" /usr/local/bin/spice-web-client/run.js && \
    sed -i "s/data\['spice_port'\] || 0/document.getElementById('port').value/g" /usr/local/bin/spice-web-client/run.js && \
    sed -i "s/data\['spice_password'\] || ''/document.getElementById('password').value/g" /usr/local/bin/spice-web-client/run.js && \
    # Create systemd service to launch html5 SPICE
    echo '[Unit]\nDescription=HTML5 SPICE WebSocket proxy\nAfter=syslog.target network.target\n\n[Service]\nUser=lightdm\nType=simple\nExecStart=/usr/local/bin/websockify 5800 localhost:5900 --web /usr/local/bin/spice-web-client\nTimeoutStopSec=20\nKillMode=process\nRestart=always\nRestartSec=2\n\n[Install]\nWantedBy=multi-user.target\nAlias=websocket.service\n' > /lib/systemd/system/websocket.service && \
    ln -snf /lib/systemd/system/websocket.service \
       /etc/systemd/system/multi-user.target.wants/websocket.service && \
    # Script to launch Xspice "pretending" to be Xvnc
    echo '#!/bin/bash\nif [ "$1" == ":2" ]; then\n  Xspice $1 -ac -noreset -nolisten tcp --port 5902 --password $(cat /tmp/lightdm/.xserver-xspice-passwd) --vdagent --video-codecs ${SPICE_VIDEO_CODECS:-gstreamer:h264;gstreamer:vp8;gstreamer:mjpeg;spice:mjpeg} --deferred-fps 60 > /dev/null &\n  XSPICE_PID=$!\n  cleanup() {\n    kill -TERM $XSPICE_PID\n  }\n  trap cleanup SIGINT SIGTERM EXIT\n  sleep 0.25\n  kill -USR1 $PPID\nfi\nsocat - TCP:localhost:5902' > /usr/bin/Xspice-lightdm-wrapper && \
    chmod +x /usr/bin/Xspice-lightdm-wrapper && \
    echo '[LightDM]\nminimum-display-number=1\n[Seat:*]\nuser-session=ubuntu-xorg\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper\n[VNCServer]\nenabled=true\ncommand=Xspice-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-ubuntu.conf

VOLUME /tmp/audio-fifo

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t ubuntu-gnome-spice:18.04 .

