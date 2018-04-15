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

FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

#    apt-get -fy -o Dpkg::Options::="--force-confnew" -o APT::Immediate-Configure=false #dist-upgrade && \

RUN \
    # Set up the repositories for Linux Mint Sylvia
    echo "deb http://packages.linuxmint.com/ sylvia main upstream import backport\n\n$(cat /etc/apt/sources.list)" > /etc/apt/sources.list.d/official-package-repositories.list && \
    rm /etc/apt/sources.list && \
    LINUX_MINT_KEY=$(apt update 2>&1 | grep -o '[0-9A-Z]\{16\}$' | xargs) && \
    apt-key adv --recv-keys --keyserver \
    hkp://keyserver.ubuntu.com:80 ${LINUX_MINT_KEY} && \
    apt-get update && \
    apt-get -fy -o Dpkg::Options::="--force-confnew" -o APT::Immediate-Configure=false dist-upgrade && \
    apt-get install -y --allow-unauthenticated linuxmint-keyring && \
    unset LINUX_MINT_KEY && \
    # Add the main Mint flavoured packages
    apt-get install -y --no-install-recommends \
    base-files ntp apt-utils add-apt-key apt-transport-https apt-xapian-index \
    locales language-pack-en tzdata mintlocale mint-meta-cinnamon mintupload \
    mint-user-guide-cinnamon mint-info-cinnamon mintnanny mintreport \
    # Add additional packages to be similar to Mint iso installation.
    gnome-terminal keyboard-configuration libreoffice gimp xed firefox \
    firefox-locale-en thunderbird thunderbird-gnome-support hexchat \
    pidgin transmission-gtk pix gnome-calculator gnome-screenshot \
    gucharmap xreader xviewer xplayer rhythmbox tomboy simple-scan \
    vlc vlc-data baobab gnome-power-manager gufw \
    gnome-system-log gnome-system-monitor blueberry vino gnome-disk-utility \
    pulseaudio libpulsedsp pulseaudio-utils paman paprefs libcanberra-pulse \
    pulseaudio-module-x11 pulseaudio-module-bluetooth gstreamer1.0-pulseaudio \
    gstreamer0.10-pulseaudio pulseaudio-module-zeroconf pavucontrol \
    avahi-utils libnss-mdns mesa-utils \
    cups system-config-printer-gnome system-config-printer-udev && \
    # Tidy up
    apt-get -y autoremove && \
    apt-get clean && \
    # Generate locales
    echo LANG=$LANG > /etc/default/locale && \
    update-locale LANG=$LANG && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure tzdata && \
    # Configure console
    echo console-setup console-setup/charmap select UTF-8 | debconf-set-selections && \
    # Fix mintupdate "APT-cache damaged" error
    cp /usr/share/linuxmint/mintsystem/apt/official-package-repositories.pref \
       /etc/apt/preferences.d/official-package-repositories.pref && \
    # Fix synaptic Empty Dir::Cache::pkgcache setting not handled correctly
    # https://bugs.launchpad.net/ubuntu/+source/synaptic/+bug/1243615
    # which causes synaptic to barf with:
    # E: Could not open file - open (2: No such file or directory)
    # E: _cache->open() failed, please report.
    sed -i 's/Dir::Cache::pkgcache ""; //' /etc/apt/apt.conf.d/docker-clean && \
    # Remove some unnecessary files from /etc/X11/Xsession.d The files in
    # this directory are called by /etc/X11/Xsession and the ones below run
    # X clients (xhost and xrdb), this causes Xephyr to terminate prematurely
    # as we have set Xephyr to reset and terminate after last client exits.
    rm /etc/X11/Xsession.d/30x11-common_xresources && \
    rm /etc/X11/Xsession.d/35x11-common_xhost-local && \
    rm /etc/X11/Xsession.d/60x11-common_localhost && \
    # Fix issues with slow shutdown
    sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf


#     rm -rf /var/lib/apt/lists/* && \
# mintwifi mint-kernel-info mint-search-addon mint-meta-codecs
# mintdesktop lightdm-settings
# mdm mint-mdm-themes mint-mdm-themes-gdm mint-mdm-themes-html \

#ENTRYPOINT ["/sbin/init"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t linuxmint-cinnamon:18 .

