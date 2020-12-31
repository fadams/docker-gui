#!/bin/bash
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

BIN=$(cd $(dirname $0); echo ${PWD%docker-gui*})docker-gui/bin
. $BIN/docker-xauth.sh
. $BIN/docker-gpu.sh
. $BIN/docker-pulseaudio.sh
. $BIN/docker-dbus-all.sh

# If Docker --security-opt apparmor=unconfined is set the process is
# still confined by any relevant AppArmor profile present on the host.
# On Linux Mint 20, and probably other distros, the host's libreoffice
# AppArmor profile appears to deny filesystem X11 sockets /tmp/.X11-unix/
# and allow only the abstract sockets. This prevents libreoffice
# connecting to the display from a container. A workaround is to add
# --network=host, though this reduces security even more. A better
# approach is to enable the docker-dbus AppArmor profile available
# in docker-gui/bin/docker-dbus
if [[ $APPARMOR_FLAGS == "--security-opt apparmor=unconfined" ]]; then
    echo "Warning: Host's libreoffice AppArmor profile only allows abstract X11"
    echo "socket @/tmp/.X11-unix/ and denies filesystem X11 socket /tmp/.X11-unix/"
    echo "Adding --network=host flag to allow connection to the abstract socket."
    APPARMOR_FLAGS+=" --network=host"
fi

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/pulse
mkdir -p $(id -un)/.config/dconf
$DOCKER_COMMAND run --rm \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    $PULSEAUDIO_FLAGS \
    $X11_FLAGS \
    $GPU_FLAGS \
    libreoffice-opencl

