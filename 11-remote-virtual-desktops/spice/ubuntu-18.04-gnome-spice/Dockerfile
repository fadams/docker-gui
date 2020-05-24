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
#FROM linuxmint-cinnamon-vgl:19.3

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
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
    # Script to launch Xspice "pretending" to be Xvnc
    echo '#!/bin/bash\nSPICEPORT=$((5900+${1#:}))\nif [ "$SPICEPORT" == 5902 ]; then\nXspice $1 -ac -noreset -nolisten tcp --port $SPICEPORT --disable-ticketing --vdagent --video-codecs ${SPICE_VIDEO_CODECS:-gstreamer:h264;gstreamer:vp8;gstreamer:mjpeg;spice:mjpeg} --deferred-fps 60 > /dev/null &\nXSPICE_PID=$!\ncleanup() {\n  kill -TERM $XSPICE_PID\n}\ntrap cleanup SIGINT SIGTERM EXIT\nsleep 0.25\nkill -USR1 $PPID\nfi\n#socat - TCP:localhost:$SPICEPORT\nsocat - TCP:localhost:5902' > /usr/bin/Xspice-lightdm-wrapper && \
    chmod +x /usr/bin/Xspice-lightdm-wrapper && \
    echo '[LightDM]\nminimum-display-number=1\n[Seat:*]\nuser-session=ubuntu-xorg\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper\n[VNCServer]\nenabled=true\ncommand=Xspice-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-ubuntu.conf

VOLUME /tmp/audio-fifo

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t ubuntu-gnome-spice:18.04 .


# SPICEPORT=$((5900+${1#:}))
# if [ "$SPICEPORT" == 5902 ]; then
# Xspice $1 -ac -noreset -nolisten tcp --auto --numheads 1 --port $SPICEPORT --disable-ticketing --vdagent --video-codecs ${SPICE_VIDEO_CODECS:-gstreamer:h264;gstreamer:vp8;gstreamer:mjpeg;spice:mjpeg} --deferred-fps 60 --audio-fifo-dir /tmp/audio-fifo > /dev/null &
# XSPICE_PID=$!
# cleanup() {
#   kill -TERM $XSPICE_PID
# }
# trap cleanup SIGINT SIGTERM EXIT
# sleep 0.25
# kill -USR1 $PPID
# fi
# #socat - TCP:localhost:$SPICEPORT
# socat - TCP:localhost:5902

