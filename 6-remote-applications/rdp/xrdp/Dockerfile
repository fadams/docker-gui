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

RUN sed -i 's/main/main non-free/' /etc/apt/sources.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    wget apt-utils git autoconf automake libtool software-properties-common \
    nasm xsltproc flex bison pkg-config locales \
    libssl-dev libpam0g-dev libx11-dev xserver-xorg-dev xserver-xorg-core \
    libxfixes-dev libxrandr-dev libxml2-dev dpkg-dev libcap-dev \
    libmp3lame-dev libopus-dev libfdk-aac-dev libjpeg-dev \
    libturbojpeg0-dev libpixman-1-dev libfuse-dev \
    libgl1-mesa-glx libgl1-mesa-dri jwm xauth x11-utils \
    xfonts-base xfonts-75dpi xfonts-100dpi xfonts-scalable && \
    #
    # Install tini. Can't just use --init in docker run because we need
    # tini's -g option so every process in the group gets the signal
    wget -O /sbin/init https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    chmod +x /sbin/init && \
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
    # Clone xrdp and xorgxrdp source from GitHub and build them.
    cd /usr/src && \
    git clone --recursive https://github.com/neutrinolabs/xrdp.git && \
    git clone https://github.com/neutrinolabs/xorgxrdp.git && \
    cd xrdp && git checkout v0.9.9 -b build && \
    # The default xrdp behaviour is to defer starting Xorg until
    # session start, so we patch session.c to prevent it skipping
    # the display we will be pre-starting.
    sed -i 's/!x_server_running_check_ports(display)/1/' \
        /usr/src/xrdp/sesman/session.c && \
    ./bootstrap && \
    ./configure --enable-mp3lame --enable-opus --enable-fdkaac \
                --enable-jpeg --enable-tjpeg --enable-pixman --enable-fuse \
                --enable-ipv6 --enable-vsock && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    cd ../xorgxrdp && git checkout v0.2.9 -b build && \
    ./bootstrap && ./configure && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    sed -i 's/ssl_protocols=TLSv1.2, TLSv1.3/ssl_protocols=TLSv1.2/' \
        /etc/xrdp/xrdp.ini && \
    # Make the log files writeable so that xrdp needn't be root.
    touch /var/log/xrdp.log && chmod 1777 /var/log/xrdp.log && \
    touch /var/log/xrdp-sesman.log && chmod 1777 /var/log/xrdp-sesman.log && \
    chmod 644 /etc/xrdp/rsakeys.ini && \
    chmod 644 /etc/xrdp/cert.pem && \
    chmod 644 /etc/xrdp/key.pem && \
    chmod 666 /etc/xrdp/sesman.ini && \
    #
    # We'll be exporting /tmp/.X11-unix as a volume
    # and we need the mode of /tmp/.X11-unix to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    #
    # Create Fake Xorg for xrdp to use on session start.
    echo '#!/bin/bash\nsleep infinity' > /usr/lib/xorg/XorgFake && \
    chmod +x /usr/lib/xorg/XorgFake && \
    sed -i 's/param=Xorg/param=\/usr\/lib\/xorg\/XorgFake/' /etc/xrdp/sesman.ini && \
    #
    # Create launch script to start Xorg, jwm and xrdp. The sed replaces
    # X11DisplayOffset with $DISPLAY using an explicit temp file in /tmp
    # because /etc/xrdp isn't writable so we can't use sed -i
    echo '#!/bin/bash\nsed '\"'s/X11DisplayOffset=10/X11DisplayOffset=${DISPLAY:1}/'\"' /etc/xrdp/sesman.ini > /tmp/sesman.ini && cat /tmp/sesman.ini > /etc/xrdp/sesman.ini && rm -f /tmp/sesman.ini\nXorg $DISPLAY -ac -noreset -nolisten tcp -config /etc/X11/xrdp/xorg.conf &\nxrdp-sesman --nodaemon &\nexec xrdp --nodaemon' > /usr/local/bin/startup && \
    chmod +x /usr/local/bin/startup && \
    #
    # Remove miscellaneous packages used for installation and build.
    # Need to keep pkg-config or xrdp-chansrv behaves weirdly.
    rm -rf /usr/src/xrdp && \
    rm -rf /usr/src/xorgxrdp && \
    apt-get clean && \
    apt-get purge -y \
    wget apt-utils git autoconf automake libtool software-properties-common \
    nasm xsltproc flex bison gcc-6 libgcc-6-dev binutils xz-utils \
    libpython3.5-minimal libx11-dev xserver-xorg-dev bzip2 && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix

# The -g option here is important for cleanly shutting down.
# See https://github.com/krallin/tini#process-group-killing
ENTRYPOINT ["/sbin/init", "-g", "--"]
CMD ["/usr/local/bin/startup"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xrdp .
#

