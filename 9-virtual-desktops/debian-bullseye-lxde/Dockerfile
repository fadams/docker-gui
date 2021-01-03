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

FROM debian:bullseye

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

RUN \
    # Update base packages.
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get -fy -o Dpkg::Options::="--force-confnew" \
                -o APT::Immediate-Configure=false \
                dist-upgrade && \
    # Add the main packages
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    base-files vim ntp locales apt-transport-https curl \
    lxde lxde-settings-daemon lxlock lxmusic desktop-base \
    synaptic libnss-mdns thunderbird inkscape pidgin \
    gimp gimp-help-en transmission-gtk tracker-miner-fs \
    avahi-utils avahi-discover firefox-esr-l10n-en-gb \
    vlc mesa-utils thunderbird-l10n-en-gb libpam-kwallet5 \
    remmina remmina-common remmina-plugin-rdp \
    remmina-plugin-vnc remmina-plugin-nx \
    remmina-plugin-spice remmina-plugin-xdmcp sudo geany \
    libcanberra-pulse pulseaudio-module-bluetooth paprefs \
    pavucontrol gstreamer1.0-pulseaudio cups-pk-helper \
    pulseaudio-module-zeroconf cups system-config-printer \
    # Install Display Manager and dependencies
    lightdm slick-greeter dbus-x11 && \
    # Stop synaptic package manager being painfully slow
    rm /etc/apt/apt.conf.d/docker-gzip-indexes && \
    rm -rf /var/lib/apt/lists/* && apt-get update && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && \
    locale-gen && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure tzdata && \
    # Configure LightDM Display Manager to use Xephyr 
    # instead of X. Reorganise /usr/share/xsessions to set
    # LXDE as default session as slick-greeter uses
    # hardcoded names to select the default session.
    rm /usr/share/xsessions/lightdm-xsession.desktop && \
    rm /usr/share/xsessions/openbox.desktop && \
    # Need to set dpi here for LXDE or fonts are HUGE
    echo '#!/bin/bash\nexport XAUTHORITY=/root/.Xauthority.docker\nexport DISPLAY=:0\nexec Xephyr $1 -ac -dpi 48 >> /var/log/lightdm/x-1.log' > /usr/bin/Xephyr-lightdm-wrapper && \
    chmod +x /usr/bin/Xephyr-lightdm-wrapper && \
    # Debian LightDM config is in /etc/lightdm/lightdm.conf
    echo '[LightDM]\nminimum-display-number=1\n[Seat:*]\nsession-setup-script=sh -c "xdpyinfo | grep -q RANDR && exec xrandr --output default --mode 1600x1200 || true"\ngreeter-hide-users=false\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper' > /etc/lightdm/lightdm.conf && \
    # Ensure LightDM is set as Display Manager
    rm -f /etc/systemd/system/display-manager.service && \
    ln -s /lib/systemd/system/lightdm.service \
          /etc/systemd/system/display-manager.service && \
    echo '/usr/sbin/lightdm' > \
         /etc/X11/default-display-manager && \
    # Set greeter background
    echo '[Greeter]\nbackground=/usr/share/desktop-base/futureprototype-theme/plymouth/plymouth_background_future.png\n' > /etc/lightdm/slick-greeter.conf && \
    # Set up Keyboard mapping
    echo 'XKBMODEL="pc105"\nXKBLAYOUT="gb"\nXKBVARIANT=""\nXKBOPTIONS=""' > /etc/default/keyboard && \
    # Configure console
    echo "console-setup console-setup/charmap select UTF-8" | debconf-set-selections && \
    # Fix synaptic Empty Dir::Cache::pkgcache setting not
    # handled correctly https://bugs.launchpad.net/ubuntu/+source/synaptic/+bug/1243615
    # which causes synaptic to barf with: E: Could not 
    # open file - open (2: No such file or directory)
    # E: _cache->open() failed, please report.
    sed -i 's/Dir::Cache::pkgcache "";//' \
        /etc/apt/apt.conf.d/docker-clean && \
    # Disable getty@tty1.service to speed up desktop loading.
    rm -f /etc/systemd/system/getty.target.wants/getty@tty1.service && \
    # Fix issues with slow shutdown
    sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf && \
    # Fix Polkit issues caused by container login being
    # considered to be an "inactive" session.
    chmod 755 /etc/polkit-1/localauthority && \
    # Shutdown & Restart
    # Note that auth_admin_keep may be better than yes
    # here, but there seems to be an issue with the
    # authentication dialog appearing.
    echo "[Shutdown & Restart]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-shutdown.pkla

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t debian-lxde:bullseye .

