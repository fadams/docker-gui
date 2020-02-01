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

# Install x2goserver and xserver-xorg-video-dummy.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates libgl1-mesa-glx libgl1-mesa-dri jwm \
    gnupg dirmngr locales xserver-xorg-video-dummy && \
    # Set up the repositories for x2go
    echo "deb http://packages.x2go.org/debian stretch extras main\n" > /etc/apt/sources.list.d/x2go.list && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 E1F958385BFE2B6E && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    x2goserver && \
    # Create simple launch script to start x2goserver.
    echo '#!/bin/bash\nif ! test -d "${HOME}/.ssh"; then\nmkdir ${HOME}/.ssh\nssh-keygen -f ${HOME}/.ssh/ssh_host_rsa_key -N "" -t rsa -b 4096\nssh-keygen -f ${HOME}/.ssh/ssh_host_ecdsa_key -N "" -t ecdsa -b 521\nssh-keygen -f ${HOME}/.ssh/ssh_host_ed25519_key -N "" -t ed25519\nfi\nXorg $DISPLAY -ac -cc 4 &\nsleep 0.5\njwm &\necho "$(id -un)@${DISPLAY}" > ${HOME}/.session_id\n\n/usr/sbin/sshd -p 2222 -D -h ${HOME}/.ssh/ssh_host_rsa_key -h ${HOME}/.ssh/ssh_host_ecdsa_key -h ${HOME}/.ssh/ssh_host_ed25519_key' > /usr/local/bin/start-server && \
    chmod +x /usr/local/bin/start-server && \
    # Overwrite x2golistdesktops with simple script to
    # return running desktop.
    echo '#!/bin/bash\ncat ${HOME}/.session_id' > \
         /usr/bin/x2golistdesktops && \
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
    # We'll be exporting /tmp/.X11-unix as a volume
    # and we need the mode of /tmp/.X11-unix to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    # sshd privilege separation directory
    mkdir /run/sshd && \
    rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix

COPY xorg.conf /etc/X11/xorg.conf

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t x2goserver .
#

