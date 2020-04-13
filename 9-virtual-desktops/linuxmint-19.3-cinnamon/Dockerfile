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

FROM ubuntu:18.04

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends gnupg && \
    # Enable partner repository (for mint-meta-codecs)
    sed -i 's/# deb http:\/\/archive.canonical.com\/ubuntu bionic partner/deb http:\/\/archive.canonical.com\/ubuntu bionic partner/' /etc/apt/sources.list && \
    # Remove "This system has been minimized" warning.
    rm -f /etc/update-motd.d/60-unminimize && \
    # Set up the repositories for Linux Mint 19.3 "Tricia"
    echo "deb http://packages.linuxmint.com/ tricia main upstream import backport\n\n$(cat /etc/apt/sources.list)" > /etc/apt/sources.list.d/official-package-repositories.list && \
    rm /etc/apt/sources.list && \
    LINUX_MINT_KEY=$(apt update 2>&1 | \
        grep -o '[0-9A-Z]\{16\}$' | xargs) && \
    apt-key adv --recv-keys --keyserver \
    hkp://keyserver.ubuntu.com:80 ${LINUX_MINT_KEY} && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get -fy -o Dpkg::Options::="--force-confnew" \
                -o APT::Immediate-Configure=false \
                dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --allow-unauthenticated \
        linuxmint-keyring && \
    unset LINUX_MINT_KEY && \
    # Add the main Mint flavoured packages
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    base-files ntp apt-utils add-apt-key aptdaemon \
    apt-transport-https locales tzdata language-pack-en \
    language-pack-gnome-en mintlocale mint-meta-cinnamon \
    mintupload mint-common mint-meta-core mint-themes \
    mintdesktop mintmenu mintstick mintsystem mintwelcome \
    xserver-xephyr wamerican cinnamon-core cinnamon-doc \
    cinnamon-desktop-environment mint-info-cinnamon \
    mintnanny mintreport mint-meta-codecs wbritish \
    # Add packages to be similar to Mint iso installation.
    gnome-terminal keyboard-configuration pidgin xed \
    gimp gimp-help-en hexchat firefox firefox-locale-en \
    libreoffice openoffice.org-hyphenation thunderbird \
    thunderbird-locale-en thunderbird-gnome-support \
    gucharmap remmina remmina-common remmina-plugin-rdp \
    remmina-plugin-vnc remmina-plugin-nx gvfs-backends \
    remmina-plugin-spice remmina-plugin-xdmcp drawing \
    transmission-gtk pix rhythmbox gnome-calculator \
    gnome-screenshot xreader xviewer xplayer gnote \
    simple-scan inkscape vlc vlc-data baobab blueberry \
    gnome-power-manager gufw dmz-cursor-theme vino \
    gnome-system-log gnome-system-monitor libglu1-mesa \
    gnome-disk-utility pulseaudio libpulsedsp paprefs \
    pulseaudio-utils libcanberra-pulse pavucontrol \
    pulseaudio-module-bluetooth gstreamer1.0-pulseaudio \
    pulseaudio-module-zeroconf avahi-utils libnss-mdns \
    mesa-utils cheese cups system-config-printer-gnome \
    colord system-config-printer-udev gnome-keyring \
    libpam-gnome-keyring libpam-kwallet4 libpam-kwallet5 \
    # Install Display Manager and dependencies
    lightdm slick-greeter dbus-x11 && \
    # Default libgl1-mesa-dri causes "black window" issues
    # when software rendering. Use ppa to upgrade version.
    add-apt-repository -y ppa:oibaf/graphics-drivers && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y libgl1-mesa-dri && \
    # Stop synaptic package manager being painfully slow
    rm /etc/apt/apt.conf.d/docker-gzip-indexes && \
    rm -rf /var/lib/apt/lists/* && apt-get update && \
    # Generate locales
    echo LANG=$LANG > /etc/default/locale && \
    update-locale LANG=$LANG && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure tzdata && \
    # Configure LightDM Display Manager to use
    # Xephyr instead of X
    echo '#!/bin/bash\nexport XAUTHORITY=/root/.Xauthority.docker\nexport DISPLAY=:0\nexec Xephyr $1 -ac >> /var/log/lightdm/x-1.log' > /usr/bin/Xephyr-lightdm-wrapper && \
    chmod +x /usr/bin/Xephyr-lightdm-wrapper && \
    echo '[LightDM]\nminimum-display-number=1\n[Seat:*]\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-linuxmint.conf && \
    # Change nemo icons from standard to small
    # https://unix.stackexchange.com/questions/250266/rhel-7-gnome-shell-decrease-desktop-icon-size
    sed -i '/default-zoom-level/{n; s/standard/small/}' \
      /usr/share/glib-2.0/schemas/org.nemo.gschema.xml && \
    glib-compile-schemas /usr/share/glib-2.0/schemas/ > \
        /dev/null 2>&1 && \
    # Configure console
    echo "console-setup console-setup/charmap select UTF-8" | debconf-set-selections && \
    # Fix mintupdate "APT-cache damaged" error
    cp /usr/share/linuxmint/mintsystem/apt/official-package-repositories.pref \
       /etc/apt/preferences.d/official-package-repositories.pref && \
    # Fix synaptic Empty Dir::Cache::pkgcache setting not
    # handled correctly https://bugs.launchpad.net/ubuntu/+source/synaptic/+bug/1243615
    # which causes synaptic to barf with: E: Could not 
    # open file - open (2: No such file or directory)
    # E: _cache->open() failed, please report.
    sed -i 's/Dir::Cache::pkgcache ""; //' \
        /etc/apt/apt.conf.d/docker-clean && \
    # Disable getty@tty1.service to speed up desktop loading.
    rm -f /etc/systemd/system/getty.target.wants/getty@tty1.service && \
    # Fix issues with slow shutdown
    sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf && \
    # Fix Polkit issues caused by container login being
    # considered to be an "inactive" session.
    chmod 755 /etc/polkit-1/localauthority && \
    # Mint Software Sources
    echo "[Mint Software Sources]\nIdentity=unix-user:*\nAction=com.linuxmint.mintsources\nResultAny=auth_self_keep\nResultInactive=auth_self_keep\nResultActive=auth_self_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-mintsources.pkla && \
    # Date & Time
    echo "[Date & Time]\nIdentity=unix-user:*\nAction=org.cinnamon.settingsdaemon.datetimemechanism.configure\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-datetimemechanism.pkla  && \
    # Gnome System Log
    echo "[Gnome System Log]\nIdentity=unix-user:*\nAction=org.debian.pkexec.gnome-system-log.run\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-system-log.pkla && \
    # Shutdown & Restart
    # Note that auth_admin_keep may be better than yes
    # here, but there seems to be an issue with the
    # authentication dialog appearing.
    echo "[Shutdown & Restart]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-shutdown.pkla

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t linuxmint-cinnamon:19.3 .

