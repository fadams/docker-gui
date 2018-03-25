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

# Make sure APT operations are non-interactive
ENV DEBIAN_FRONTEND noninteractive

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

#    apt-get -fy -o Dpkg::Options::="--force-confnew" -o APT::Immediate-Configure=false #dist-upgrade && \

RUN \
    # Set up the repositories for Linux Mint sylvia
    echo "deb http://packages.linuxmint.com/ sylvia main upstream import backport " > /etc/apt/sources.list.d/mint.list && \
    LINUX_MINT_KEY=$(apt update 2>&1 | grep -o '[0-9A-Z]\{16\}$' | xargs) && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com ${LINUX_MINT_KEY} && \
    apt-get update && \
    apt-get -fy -o Dpkg::Options::="--force-confnew" -o APT::Immediate-Configure=false dist-upgrade && \
    apt-get install -y --allow-unauthenticated linuxmint-keyring && \
    unset LINUX_MINT_KEY && \
    # Add the main packages
    apt-get install -y --no-install-recommends \
    base-files ntp apt-utils locales language-pack-en tzdata \
    cinnamon cinnamon-core cinnamon-themes \
    mint-info-cinnamon mint-x-icons mint-y-icons grub2-theme-mint mint-artwork-cinnamon \
    mint-artwork-common mint-artwork-gnome mint-common mint-meta-core \
    mint-mirrors mint-themes mint-themes-gtk3 mint-translations \
    mint-user-guide-cinnamon mint-meta-cinnamon mintsystem mintwelcome \
    mint-mdm-themes mint-mdm-themes-gdm mint-mdm-themes-html mintnanny \
    mintupdate mint-upgrade-info mintlocale mintsources mintstick \
    mdm mintupload mintbackup mintdrivers mintinstall \
    mint-backgrounds-sylvia libreoffice-style-mint mintdesktop mintmenu \
    gnome-terminal keyboard-configuration libreoffice gimp xed firefox && \
    # Tidy up
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Generate locales
    echo LANG=$LANG > /etc/default/locale && \
    update-locale LANG=$LANG && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure tzdata && \
    # Configure console
    echo console-setup console-setup/charmap select UTF-8 | debconf-set-selections



# mintwifi mint-kernel-info mint-search-addon mint-meta-codecs

#ENTRYPOINT ["/sbin/init"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t linuxmint-cinnamon:18 .

