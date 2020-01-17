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

# Install xserver-xorg-video-dummy and tigervnc-xorg-extension
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-dummy \
    tigervnc-xorg-extension tigervnc-common locales jwm && \
    rm -rf /var/lib/apt/lists/* && \
    # Create simple launch script to start Xorg and jwm 
    # Need to create a symlink from real password file at run-time
    # as xorg.conf options seem to need absolute paths.
    mkdir /usr/local/etc/.vnc && \
    chmod 777 /usr/local/etc/.vnc && \
    echo '#!/bin/bash\nln -s ~/.vnc/passwd /usr/local/etc/.vnc/passwd\nXorg $DISPLAY -cc 4 &\nsleep 0.5\njwm' > /usr/local/bin/startup && \
    chmod +x /usr/local/bin/startup && \
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
    # We'll be exporting /tmp/.X11-unix as a volume and we need
    # the mode of /tmp/.X11-unix to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

VOLUME /tmp/.X11-unix

COPY xorg.conf /etc/X11/xorg.conf

CMD ["/usr/local/bin/startup"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t tigervnc-xdummy .
#

