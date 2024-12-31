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

################################################################################
# This script uses the simple approach of sharing the host's X11 socket with
# the container. This method requires the container and display to be on the
# same host, but gives performance that is equivalent to running the application
# directly (i.e. not in a container) on the host.
# This script creates an additional .Xauthority file based on the user's but
# with a wildcard hostname to avoid having to set the container's hostname.
# This script uses the -u option of docker run to reduce the privileges of the
# container to that of the user running the script, bind mounting /etc/passwd
# read only isn't strictly necessary but allows the container to map the user's
# ID to name to avoid seeing "I have no name!" when launching a shell.
# In this script we have added configuration so that the container will work
# properly with dconf/D-bus:
#    --net host \
#    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
#    -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
################################################################################

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

if [[ $DBUS_SESSION_BUS_ADDRESS == *"abstract"* ]]; then
    DBUS_FLAGS="--net=host"
else
    DBUS_FLAGS="-v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro -v $XDG_RUNTIME_DIR/at-spi:$XDG_RUNTIME_DIR/at-spi:ro"
fi

# Add flags for connecting to the D-bus system bus.
# This is necessary in order to connect to colord, a service
# that makes it easy to manage, install and generate colour
# profiles to accurately colour manage devices. 
# https://www.freedesktop.org/software/colord/intro.html
DBUS_FLAGS="-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro "$DBUS_FLAGS

# After updating my host to Mint 22 (based on Ubuntu 24.04) printer wasn't
# visible via dbus alone and I needed to explicitly mount cups socket.
# Not sure why TBH, dbus is a bit like "magic" unfortunately.
DBUS_FLAGS="-v /run/cups/cups.sock:/run/cups/cups.sock "$DBUS_FLAGS

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
   simple-scan $@

# Example usage:
# ./network-simple-scan.sh net:172.17.0.1:epson2:libusb:001:006

