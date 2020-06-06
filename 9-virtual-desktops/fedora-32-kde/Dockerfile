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

FROM fedora:32

ENV LANG=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8
ENV TZ=Europe/London

RUN dnf -y update && \
    dnf -y install \
    xorg-x11-server-utils xorg-x11-utils xorg-x11-xinit && \
    dnf -y groups install "KDE Plasma Workspaces" || true && \
    dnf -y groups install "KDE Applications" && \
    dnf -y groups install "KDE Multimedia support" && \
    dnf -y groups install "LibreOffice" && \
    dnf -y install \
    xorg-x11-server-Xephyr passwd procps cracklib-dicts \
    ntp glibc-locale-source glibc-langpack-en thunderbird \
    open-sans-fonts firefox pulseaudio-module-zeroconf \
    pavucontrol gimp inkscape nss-mdns mesa-libGLU \
    # Install Display Manager and dependencies
    lightdm slick-greeter dbus-x11 || true && \
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
    # instead of X.
    echo -e '#!/bin/bash\nexport XAUTHORITY=/root/.Xauthority.docker\nexport DISPLAY=:0\nexec Xephyr $1 -ac >> /var/log/lightdm/x-1.log' > /usr/bin/Xephyr-lightdm-wrapper && \
    chmod +x /usr/bin/Xephyr-lightdm-wrapper && \
    echo -e '[LightDM]\nminimum-display-number=1\n[Seat:*]\nsession-setup-script=sh -c "xdpyinfo | grep -q RANDR && exec xrandr --output default --mode 1600x1200 || true"\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-fedora.conf && \
    # Change default Display Manager to LightDM
    rm -f /etc/systemd/system/display-manager.service && \
    ln -s /usr/lib/systemd/system/lightdm.service \
          /etc/systemd/system/display-manager.service && \
    # Set greeter background
    echo -e '[Greeter]\nbackground=/usr/share/wallpapers/F32/contents/images/1600x1200.png\n' > /etc/lightdm/slick-greeter.conf && \
    # Fedora defaults init to multi-user.target,
    # change to graphical.target
    rm -f /etc/systemd/system/default.target && \
    ln -s /usr/lib/systemd/system/graphical.target \
          /etc/systemd/system/default.target && \
    # Stop fonts being HUGE. Is there a better way?  
    echo -e 'mkdir -p ~/.config\nif [ ! -f ~/.config/kcmfonts ]; then\necho -e "[General]\ndontChangeAASettings=true\nforceFontDPI=96\n" > ~/.config/kcmfonts\nfi' > /etc/profile.d/fix-fonts.sh && \
    # Fedora 32 defaults to using dbus-broker rather than 
    # dbus-daemon which seems to cause some significant 
    # systemd issues, so revert back to dbus-daemon.
    # First disable dbus-broker
    rm /etc/systemd/system/dbus.service && \
    # Needed for Fedora 31 breaks Fedora 32!! so use -f
    rm -f /etc/systemd/system/messagebus.service && \
    # The enable dbus-daemon
    ln -s /usr/lib/systemd/system/dbus-daemon.service \
          /etc/systemd/system/dbus.service && \
    ln -s /usr/lib/systemd/system/dbus-daemon.service \
          /etc/systemd/system/messagebus.service && \
    ln -s /usr/lib/systemd/system/dbus-daemon.service \
          /etc/systemd/system/multi-user.target.wants/dbus-daemon.service && \
    # Unmask systemd-logind.service
    rm /etc/systemd/system/systemd-logind.service && \
    # Fix systemd-logind.service config that borked user
    # session creation. With DevicesAllow enabled a call to
    # access("/dev/tty0", F_OK) fails with EPERM and
    # session creation fails with the error:
    # Seat has no VTs but VT number not 0 error
    # Passing in /dev/tty0 usually suppresses that failure
    # but post systemd v241 the config borked that albeit
    # hacky fix to systemd demanding hardware for seats.
    sed -i 's/DeviceAllow/#DeviceAllow/g' \
        /usr/lib/systemd/system/systemd-logind.service && \
    # Mask tmp.mount which was overwriting the X11
    # socket we were bind-mounting for Xephyr to use.
    ln -s /dev/null /etc/systemd/system/tmp.mount && \
    # Prevent PulseAudio trying to launch rtkit-daemon
    # because the container doesn't have the required caps
    # and the failures slow desktop launch.
    sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/' /etc/pulse/default.pa && \
    # Disable org.freedesktop.RealtimeKit1.service DBus svc
    rm -f /usr/share/dbus-1/system-services/org.freedesktop.RealtimeKit1.service && \
    # Fix Polkit issues caused by container login being
    # considered to be an "inactive" session.
    chmod 755 /etc/polkit-1/localauthority && \
    # dnf
    echo -e "[dnf]\nIdentity=unix-user:*\nAction=org.baseurl.DnfSystem.write;org.baseurl.DnfSystem.read\nResultAny=auth_admin_keep\nResultInactive=auth_admin_keep\nResultActive=auth_admin_keep\n" > /etc/polkit-1/localauthority/50-local.d/10-dnf.pkla && \
    # PCSC
    echo -e "[PCSC]\nIdentity=unix-user:*\nAction=org.debian.pcsc-lite.access_pcsc;org.org.debian.pcsc-lite.access_card\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-pcsc.pkla && \
    # NetworkManager
    echo -e "[NetworkManager]\nIdentity=unix-user:*\nAction=org.freedesktop.NetworkManager.network-control\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-NetworkManager.pkla && \
    # packagekit refresh
    echo -e "[packagekit]\nIdentity=unix-user:*\nAction=org.freedesktop.packagekit.system-sources-refresh\nResultAny=yes\nResultInactive=yes\nResultActive=yes\n" > /etc/polkit-1/localauthority/50-local.d/10-packagekit.pkla && \
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
# docker build -t fedora-kde:32 .

