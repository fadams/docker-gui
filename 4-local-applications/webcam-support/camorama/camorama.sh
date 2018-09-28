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
# In order for configuration to be saved correctly the host system needs to
# have gconf2 installed. This is no longer the default for modern GNOME 3
# based distros such as Ubuntu 18.04 as gconf is deprecated, so it must be
# explicitly added using sudo apt-get install gconf2.

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

if [[ $DBUS_SESSION_BUS_ADDRESS == *"abstract"* ]]; then
    DBUS_FLAGS="--net=host"
else
    DBUS_FLAGS="-v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro -e NO_AT_BRIDGE=1"
fi

# Add flags for connecting to the D-bus system bus.
DBUS_FLAGS="-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro "$DBUS_FLAGS

if test -f "/etc/apparmor.d/docker-dbus"; then
    APPARMOR_FLAGS="--security-opt apparmor:docker-dbus"
else
    APPARMOR_FLAGS="--security-opt apparmor=unconfined"
fi

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/dconf
$DOCKER_COMMAND run --rm \
    --device=/dev/video0 \
    --group-add $(cut -d: -f3 < <(getent group video)) \
    $APPARMOR_FLAGS \
    $DBUS_FLAGS \
    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
    -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    camorama

