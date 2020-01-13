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

ENV FIREFOX_LANG=en-GB
ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

# Install Firefox plus tightvncserver
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    wget bzip2 ca-certificates gnupg dirmngr procps locales \
    fonts-symbola fonts-lmodern fonts-freefont-ttf \
    fonts-liberation fonts-dejavu gsfonts \
    libgtk-3-0 libgtk2.0-0 libnss3 libxt6 libavcodec57 \
    libvpx4 libdbus-glib-1-2 libcanberra-gtk3-module \
    libpulse0 libv4l-0 libgl1-mesa-glx libgl1-mesa-dri \
    tightvncserver x11-xserver-utils jwm xfonts-base \
    xfonts-75dpi xfonts-100dpi xfonts-scalable && \
    # Debian ships with esr, so download and install latest Firefox.
    wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=${FIREFOX_LANG}" && \
    tar xjf firefox.tar.bz2 -C /usr/lib/ && \
    rm firefox.tar.bz2 && \
    rm -rf /var/lib/apt/lists/* && \
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
    # The mode of /tmp/.X11-unix needs to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

# Debian seems to have some issues with the default font
# setup. See the following blog:
# http://blog.programster.org/debian-8-gnome-desktop-improve-font-rendering/
COPY fonts.conf /etc/fonts/local.conf

CMD vncserver $DISPLAY -ac -geometry $GEOMETRY -rfbport 5900 && /usr/lib/firefox/firefox --no-remote

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t tightvnc-firefox .
#

