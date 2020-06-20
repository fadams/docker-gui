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

FROM fedora-kde-vgl:32

RUN dnf -y install \
    cmake patch gcc make autoconf libtool automake \
    pkgconfig openssl-devel gettext file pam-devel \
    git libX11-devel libXfixes-devel libjpeg-devel \
    libXrandr-devel nasm flex bison gcc-c++ libxslt \
    perl-libxml-perl xorg-x11-font-utils xmlto-tex \
    fuse-devel opus-devel lame-devel pixman-devel \
    turbojpeg-devel xorg-x11-server-devel intltool \
    libtool-ltdl-devel libcap-devel libsndfile-devel \
    speex-devel libudev-devel dbus-devel rpmdevtools \
    pulseaudio-libs-devel libXfont2-devel \
    xorg-x11-fonts-base xorg-x11-fonts-75dpi \
    xorg-x11-fonts-100dpi && \
    # Clone xrdp and xorgxrdp source from GitHub and build them.
    cd /usr/src && \
    # Need to get fdk-aac from different repo.
    curl -sSL https://li.nux.ro/download/nux/dextop/el7/x86_64/fdk-aac-0.1.4-1.x86_64.rpm -o fdk-aac-0.1.4-1.x86_64.rpm && \
    curl -sSL https://li.nux.ro/download/nux/dextop/el7/x86_64/fdk-aac-devel-0.1.4-1.x86_64.rpm -o fdk-aac-devel-0.1.4-1.x86_64.rpm && \
    rpm -i fdk-aac-0.1.4-1.x86_64.rpm fdk-aac-devel-0.1.4-1.x86_64.rpm && \
    git clone --recursive \
        https://github.com/neutrinolabs/xrdp.git && \
    git clone \
        https://github.com/neutrinolabs/xorgxrdp.git && \
    git clone \
        https://github.com/pulseaudio/pulseaudio.git && \
    git clone \
        https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
    cd xrdp && git checkout v0.9.13 -b build && \
    ./bootstrap && \
    ./configure --enable-opus --enable-fuse --enable-jpeg \
                --enable-tjpeg --enable-ipv6 --enable-vsock \
                --enable-pixman --enable-mp3lame \
                --enable-fdkaac --enable-rdpsndaudin && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    cd ../xorgxrdp && git checkout v0.2.13 -b build && \
    # Hack to make gb layout the default if client fails
    # to send correct keylayout (Vinagre seems to do that).
    # https://github.com/neutrinolabs/xrdp/issues/337
    # Replace pc105 and gb with required model and layout.
    sed -i 's/set.model = g_pc104_str;/set.model = "pc105";/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    sed -i 's/set.layout = g_us_str;/set.layout = "gb";/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    sed -i 's/strlen(client_info->layout)/0/' \
        /usr/src/xorgxrdp/xrdpkeyb/rdpKeyboard.c && \
    ./bootstrap && ./configure XRDP_CFLAGS=-I/usr/local/include && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    sed -i 's/ssl_protocols=TLSv1.2, TLSv1.3/ssl_protocols=TLSv1.2/' \
        /etc/xrdp/xrdp.ini && \
    # These lines are needed to allow 3D WM to start.
    # KDE is quite picky needing dbus-launch
    sed -i 's/readenv=1/readenv=1\nexport XAUTHORITY=$HOME\/.Xauthority.docker/' \
        /etc/xrdp/startwm.sh && \
    sed -i 's/\. \/etc\/X11\/xinit\/Xsession/    export XDG_CURRENT_DESKTOP=KDE\n    export VGL_WM=1\n    dbus-launch --sh-syntax --exit-with-session startkde/' /etc/xrdp/startwm.sh && \
    sed -i 's/param=-config/param=-ac\nparam=-config/' \
        /etc/xrdp/sesman.ini && \
    # Without the following line Fedora fails, complaining
    # Only console users are allowed to run the X server.
    echo -e "allowed_users = anybody\nneeds_root_rights = no" > /etc/X11/Xwrapper.config && \
    # Build xrdp source / sink modules
    cd ../pulseaudio && git checkout v13.99.1 -b build && \
    ./autogen.sh && \
    cd ../pulseaudio-module-xrdp && \
    git checkout v0.4 -b build && \
    ./bootstrap && \
    ./configure PULSE_DIR=/usr/src/pulseaudio && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && \
    # Modify PulseAudio daemon config to support xrdp.
    echo "load-module module-xrdp-sink" >> \
         /etc/pulse/default.pa && \
    echo "load-module module-xrdp-source" >> \
         /etc/pulse/default.pa && \
    # systemctl enable xrdp
    ln -snf /usr/lib/systemd/system/xrdp.service \
      /etc/systemd/system/multi-user.target.wants/xrdp.service

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t fedora-kde-xrdp:32 .

# Still a work in progress. Everything works fine except for audio,
# which compiles but clients report:
# [ERROR][com.freerdp.channels.rdpsnd.client] - unknown msgType 39
#
# Using v13.99.1 branch for PulseAudio GitHub doesn't work either.

