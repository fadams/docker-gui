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
. $BIN/docker-dbus-session-launch.sh # Run before dbus-all
. $BIN/docker-command.sh
. $BIN/docker-dbus-all.sh

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/pulse
mkdir -p $(id -un)/.config/dconf

# Create fake machine-id http://man7.org/linux/man-pages/man5/machine-id.5.html
# Also https://www.freedesktop.org/software/systemd/man/machine-id.html
# The issue is that containers derived from the same base image will have the
# same default machine-id (which is normally set by systemd on first boot).
# This ID is used to detect if client and server environment are identical
# and if so xpra fails to start speaker forwarding. An alternative is to set
# XPRA_ALLOW_SOUND_LOOP=1 on the environment, but setting machine-id can
# be useful in other situations too, so it's a good approach to illustrate.
if ! test -f "$(id -un)/machine-id"; then
    echo $(dbus-uuidgen) > $(id -un)/machine-id
fi

# Launch xpra exposing /tmp/.X11-unix and /run/user as volumes.
# Set XDG_RUNTIME_DIR on environment for PulseAudio daemon.
# Use -d option to daemonise and --init to run tini as pid 1
$DOCKER_COMMAND run --rm -it -d \
    --init \
    --shm-size 2g \
    --name=x11xpra \
    -p 10000:10000 \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v $PWD/$(id -un)/machine-id:/etc/machine-id \
    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
    -e DISPLAY=:1 \
    xpra start --bind=$HOME/.xpra/xpra-socket --bind-tcp=0.0.0.0:10000

# Test for the presence of $XDG_RUNTIME_DIR/pulse/pid to wait until
# xpra has launched Pulseaudio as if we launch application containers
# before the Pulseaudio socket is available then their audio will fail.
$DOCKER_COMMAND run --rm -it \
    --volumes-from x11xpra \
    xpra bash -c "while [ ! -f $XDG_RUNTIME_DIR/pulse/pid ]; do echo 'Waiting for xpra Pulseaudio daemon';sleep 1; done; echo 'xpra Pulseaudio daemon running'"

# Launch firefox. Use --volumes-from to mount /tmp/.X11-unix
# from x11xpra and also use that container's IPC
$DOCKER_COMMAND run --rm \
    --shm-size 2g \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    -e DISPLAY=:1 \
    --ipc=container:x11xpra \
    --volumes-from x11xpra \
    firefox

$DOCKER_COMMAND stop x11xpra

