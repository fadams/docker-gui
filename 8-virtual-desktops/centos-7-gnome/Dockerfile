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

FROM centos:7.4.1708

RUN \
    # When installing from yum repo it is common to see:
    # Error : Public key for *.rpm is not installed
    # This can be resolved by importing the public key files for RPM
    # which may be found by running the following command
    # docker run --rm centos:7.4.1708 find / -name *GPG*
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Testing-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7 && \
    # Install required packages
    yum -y update && \
    yum -y groups install "GNOME Desktop" || true && \
    yum -y groups install "Office Suite and Productivity" && \
    yum -y groups install "Graphics Creation Tools" && \
    yum -y install pavucontrol pulseaudio-module-zeroconf \
    && \
    # Generate locales
#    echo LANG=$LANG > /etc/default/locale && \
#    update-locale LANG=$LANG && \
    # Set up the timezone
#    echo $TZ > /etc/timezone && \
#    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
#    dpkg-reconfigure tzdata && \
    # Configure console
#    echo console-setup console-setup/charmap select UTF-8 | debconf-set-selections && \
    # Fix synaptic Empty Dir::Cache::pkgcache setting not handled correctly
    # https://bugs.launchpad.net/ubuntu/+source/synaptic/+bug/1243615
    # which causes synaptic to barf with:
    # E: Could not open file - open (2: No such file or directory)
    # E: _cache->open() failed, please report.
#    sed -i 's/Dir::Cache::pkgcache ""; //' /etc/apt/apt.conf.d/docker-clean && \
    # Fix issues with slow shutdown
    sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf && \
    # Fix Polkit issues caused by container login being considered
    # to be an "inactive" session.
    chmod 755 /etc/polkit-1/localauthority && \
    # Date & Time
    echo "[Date & Time]\nIdentity=unix-user:*\nAction=org.cinnamon.settingsdaemon.datetimemechanism.configure\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-datetimemechanism.pkla  && \
    # Xapian Index
    echo "[Xapian Index]\nIdentity=unix-user:*\nAction=org.debian.aptxapianindex.update\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-xapian.pkla && \
    # Gnome System Log
    echo "[Gnome System Log]\nIdentity=unix-user:*\nAction=org.debian.pkexec.gnome-system-log.run\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-system-log.pkla && \
    # System Color Manager
    echo "[System Color Manager]\nIdentity=unix-user:*\nAction=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile;org.freedesktop.color-manager.device-inhibit;org.freedesktop.color-manager.sensor-lock\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-color.pkla && \
    # Shutdown & Restart
    # Note that auth_admin_keep may be better than yes here, but there seems to be
    # an issue with the authentication dialog appearing.
    echo "[Shutdown & Restart]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-shutdown.pkla

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t centos-gnome:7.4 .

# FIXME
#install-info: No such file or directory for /usr/share/info/which.info.gz
#install-info: No such file or directory for /usr/share/info/nettle.info
#install-info: No such file or directory for /usr/share/info/libchewing.info
#install-info: No such file or directory for /usr/share/info/liblouis.info
#warning: /etc/yum/pluginconf.d/langpacks.conf created as /etc/yum/pluginconf.d/#langpacks.conf.rpmnew
#install-info: No such file or directory for /usr/share/info/accounting.info

# --setopt=tsflags=nodocs makes image smaller
