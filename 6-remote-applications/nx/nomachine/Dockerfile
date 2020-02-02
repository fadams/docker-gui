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

# Install NoMachine and xserver-xorg-video-dummy.
# Note net-tools as NoMachine uses netstat to detect
# if there is a currently running X Server.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl sudo ca-certificates net-tools xauth libvdpau1 \
    mesa-vdpau-drivers libgl1-mesa-glx libgl1-mesa-dri \
    desktop-base xdg-user-dirs xserver-xorg-video-dummy \
    xserver-xorg-input-libinput locales jwm cups \
    xfonts-base xfonts-75dpi xfonts-100dpi \
    xfonts-scalable pulseaudio && \
    # Install NoMachine binary and dependencies.
    # Ensure the nx user ID is not in the normal user range.
    groupadd -r -g 2000 nx && \
    useradd -u 2000 -r -g nx nx && \
    # Try to work out the latest version from the NoMachine
    # Linux download page. If this fails set the following
    # variables manually instead.
    NOMACHINE_VERSION=$(curl -sSL \
      "https://www.nomachine.com/download/download&id=3" |\
      grep "Linux/nomachine" |\
      cut -d \' -f2 | cut -d \_ -f2-3) && \
    NOMACHINE_MAJOR_VERSION=$(echo $NOMACHINE_VERSION |\
      cut -d \. -f1-2) && \
    echo "VERSION: ${NOMACHINE_VERSION}" && \
    echo "MAJOR_VERSION: ${NOMACHINE_MAJOR_VERSION}" && \
    curl -sSL https://download.nomachine.com/download/${NOMACHINE_MAJOR_VERSION}/Linux/nomachine_${NOMACHINE_VERSION}_amd64.deb -o nomachine_${NOMACHINE_VERSION}_amd64.deb && \
    dpkg -i nomachine_${NOMACHINE_VERSION}_amd64.deb && \
    # Create simple script to start NoMachine server.
    # Setting XDG_RUNTIME_DIR in /etc/environment
    # ensures the correct PulseAudio socket path
    # will be used even when PulseAudio is started
    # via sudo /etc/NX/nxserver --startup
    echo '#!/bin/bash\necho '\"'export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR'\"' | sudo tee --append /etc/environment > /dev/null\nUUID=$(cat /proc/sys/kernel/random/uuid)\nsudo sed -i '\"'s/$(cat /usr/NX/etc/uuid)/$UUID/g'\"' /usr/NX/etc/nodes.db\necho $UUID | sudo tee /usr/NX/etc/uuid > /dev/null\n\nGEOMETRY=${GEOMETRY:-1280x720}\nsudo sed -i '\"'s/Modes \\'\"'1280x720\\'\"'/Modes \\'\"'$GEOMETRY\\'\"'/g'\"' /etc/X11/xorg.conf\nXorg $DISPLAY -ac -cc 4 &\nsleep 0.5\njwm &\nwhile echo $(sudo /etc/NX/nxserver --startup) | grep WARNING; do sleep 1; done\nsudo tail -f /usr/NX/var/log/nxserver.log' > /usr/local/bin/start-server && \
    chmod +x /usr/local/bin/start-server && \
    # Modify PulseAudio daemon config.
    sed -i "s/; exit-idle-time = 20/exit-idle-time = -1/g" \
        /etc/pulse/daemon.conf && \
    sed -i "s/load-module module-console-kit/#load-module module-console-kit/g" /etc/pulse/default.pa && \
    # Allow users in sudo group to run commands without password.
    sed -i "s/%sudo\tALL=(ALL\:ALL) ALL/%sudo\tALL=(ALL\:ALL) NOPASSWD\:ALL/g" /etc/sudoers && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && \
    locale-gen && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure tzdata && \
    # Tidy up JWM for single app use case
    sed -i "s/Desktops width=\"4\"/Desktops width=\"1\"/g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton icon=\"\/usr\/share\/jwm\/jwm-red.svg\">root:1<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton label=\"_\">showdesktop<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<Include>\/etc\/jwm\/debian-menu<\/Include>//g" /etc/jwm/system.jwmrc && \
    # We'll be exporting /run/user as a volume
    # and we need the mode to be set to 1777
    mkdir /run/user && \
    chmod 1777 /run/user && \
    # Tidy up
    rm nomachine_${NOMACHINE_VERSION}_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

VOLUME /tmp/.X11-unix
VOLUME /run/user

COPY xorg.conf /etc/X11/xorg.conf

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t nomachine .
#

