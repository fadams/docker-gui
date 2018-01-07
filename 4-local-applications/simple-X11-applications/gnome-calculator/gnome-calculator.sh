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

# Issue connecting to dbus from Docker container.
#  DBus uses abstract sockets (https://unix.stackexchange.com/questions/206386/what-does-the-symbol-denote-in-the-beginning-of-a-unix-domain-socket-path-in-l),
# which are network-namespace specific.
#
# So the only real way to fix this is to not use a network namespace (i.e.
# docker run --net=host). Alternatively, you can run a process on the host which
# proxies access to the socket. I think that's what xdg-app does basically (also
# for security reasons to act as a filter).


# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

#    --net host \
#    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
#    -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \

# I don't think this is needed - though it is where /var/lib/dbus/machine-id is
#    -v /var/run/dbus/:/var/run/dbus/ \

#mkdir -p $(id -un)
mkdir -p $(id -un)/.config/dconf
docker run --rm \
--net host \
-e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
-v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
    -u $(id -u) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    gnome-calculator

