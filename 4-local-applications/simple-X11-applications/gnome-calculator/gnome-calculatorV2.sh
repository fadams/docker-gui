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
# This script uses the -u option of docker run to reduce the priviledges of the
# container to that of the user running the script, bind mounting /etc/passwd
# read only isn't strictly necessary but allows the container to map the user's
# ID to name to avoid seeing "I have no name!" when launching a shell.
################################################################################

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

if [[ $DBUS_SESSION_BUS_ADDRESS == *"abstract"* ]]; then
    DBUS_FLAGS="--net host"
else
    DBUS_FLAGS="-v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro"
fi

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)
$DOCKER_COMMAND run --rm \
    $DBUS_FLAGS \
    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
    -u $(id -u):$(id -u) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    gnome-calculator

