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

FROM centos:7.7.1908

ENV LANG=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8
ENV TZ=Europe/London

RUN \
    # When installing from yum repo it is common to see:
    # Error : Public key for *.rpm is not installed
    # This can be resolved by importing the public key files
    # for RPM, which may be found by running the following
    # docker run --rm centos:7.7.1908 find / -name *GPG*
    rpm --import \
        /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpm --import \
        /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Testing-7 && \
    rpm --import \
        /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7 && \
    # Install required packages. Add deltarpm to get rid
    # of some warnings & epel-release is needed for lightdm.
    yum -y install deltarpm epel-release && \
    yum -y update && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    yum -y --exclude=abrt* groups install \
    "GNOME Desktop" || true && \
    yum -y groups install \
    "Office Suite and Productivity" && \
    yum -y groups install \
    "Graphics Creation Tools" && \
    yum -y install \
    xorg-x11-server-Xephyr thunderbird pavucontrol lightdm \
    pulseaudio-module-zeroconf slick-greeter dbus-x11 \
    nss-mdns mesa-libGLU && \
    # Generate locales
    echo LANG=\"$LANG\" > /etc/locale.conf && \
    localedef -i "${LANG%.*}" -f "${LANG#*.}" $LANG && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    # Set up Keyboard mapping
    echo -e 'XKBMODEL="pc105"\nXKBLAYOUT="gb"\nXKBVARIANT=""\nXKBOPTIONS=""' > /etc/default/keyboard && \
    sed -i 's/KEYMAP="us"/KEYMAP="uk"/' \
        /etc/vconsole.conf && \
    sed -i 's/Option "XkbLayout" "us"/Option "XkbLayout" "gb"\n        Option "XkbModel" "pc105"\n        Option "XkbOptions" "terminate:ctrl_alt_bksp"/' /etc/X11/xorg.conf.d/00-keyboard.conf && \
    # Configure LightDM Display Manager to use Xephyr
    # instead of X. Reorganise /usr/share/xsessions to set
    # gnome-classic as default session as slick-greeter
    # uses hardcoded names to select the default session.
    mv /usr/share/xsessions/gnome.desktop \
       /usr/share/xsessions/gnome-xorg.desktop && \
    mv /usr/share/xsessions/gnome-classic.desktop \
       /usr/share/xsessions/gnome.desktop && \
    echo -e '#!/bin/bash\nexport XAUTHORITY=/root/.Xauthority.docker\nexport DISPLAY=:0\nexec Xephyr $1 -ac >> /var/log/lightdm/x-1.log' > /usr/bin/Xephyr-lightdm-wrapper && \
    chmod +x /usr/bin/Xephyr-lightdm-wrapper && \
    echo -e '[LightDM]\nminimum-display-number=1\n[Seat:*]\nsession-setup-script=xrandr --output default --mode 1600x1200\nuser-session=gnome\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-centos.conf && \
    # CentOS defaults to GDM, change to LightDM
    rm -f /etc/systemd/system/display-manager.service && \
    ln -s /usr/lib/systemd/system/lightdm.service \
          /etc/systemd/system/display-manager.service && \
    # CentOS defaults init to multi-user.target,
    # change to graphical.target
    rm -f /etc/systemd/system/default.target && \
    ln -s /usr/lib/systemd/system/graphical.target \
          /etc/systemd/system/default.target && \
    # Change nautilus and desktop icons from large to small
    # https://unix.stackexchange.com/questions/250266/rhel-7-gnome-shell-decrease-desktop-icon-size
    sed -i '/default-zoom-level/{n; s/large/small/}' \
      /usr/share/glib-2.0/schemas/org.gnome.nautilus.gschema.xml && \
    glib-compile-schemas \
        /usr/share/glib-2.0/schemas/ >/dev/null 2>&1 && \
    # Prevent PulseAudio trying to launch rtkit-daemon
    # because the container doesn't have the required caps
    # and the failures slow desktop launch.
    sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/' /etc/pulse/default.pa && \
    # Disable org.freedesktop.RealtimeKit1.service DBus svc
    rm -f /usr/share/dbus-1/system-services/org.freedesktop.RealtimeKit1.service && \
    # Fix issues with slow shutdown
    sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf && \
    # Fix Polkit issues caused by container login being
    # considered to be an "inactive" session.
    chmod 755 /etc/polkit-1/localauthority && \
    # Date & Time
    echo -e "[Date & Time]\nIdentity=unix-user:*\nAction=org.gnome.controlcenter.datetime.configure\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-datetimemechanism.pkla && \
    # User Accounts
    echo -e "[Manage user accounts]\nIdentity=unix-user:*\nAction=org.gnome.controlcenter.user-accounts.administration\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-user-accounts.pkla && \
    # Gnome System Log
    echo -e "[Gnome System Log]\nIdentity=unix-user:*\nAction=org.gnome.logview.pkexec.run\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-system-log.pkla && \
    # System Color Manager
    echo -e "[System Color Manager]\nIdentity=unix-user:*\nAction=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile;org.freedesktop.color-manager.device-inhibit;org.freedesktop.color-manager.sensor-lock\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-color.pkla && \
    # Shutdown & Restart
    # Note that auth_admin_keep may be better than yes
    # here, but there seems to be an issue with the
    # authentication dialog appearing.
    echo -e "[Shutdown & Restart]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-shutdown.pkla

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t centos-gnome:7.7 .

