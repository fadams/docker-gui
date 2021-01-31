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

# Create password if required.
if ! test -d "etc"; then
    $(cd $(dirname $0); echo $PWD)/xrdp-storepasswd.sh
fi

# Launch xrdp exposing /tmp/.X11-unix and /run/user as volumes.
# Set XDG_RUNTIME_DIR on environment for PulseAudio daemon.
# Use -d option to daemonise. Note that for this application
# we can't just use --init to run tini as pid 1, as the -g
# option is important here for cleanly shutting down.
# See https://github.com/krallin/tini#process-group-killing
# We must therefore directly install tini in the Dockerfile.
$DOCKER_COMMAND run --rm -it -d \
    --shm-size 2g \
    --name=xrdp-native-audio \
    -p 3389:3389 \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v $PWD/etc/passwd:/etc/passwd:ro \
    -v $PWD/etc/shadow:/etc/shadow:ro \
    -v $PWD/etc/group:/etc/group:ro \
    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
    -e DISPLAY=:1 \
    --ipc=shareable \
    xrdp-native-audio

$DOCKER_COMMAND run --rm \
    --shm-size 2g \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    -e DISPLAY=:1 \
    --ipc=container:xrdp-native-audio \
    --volumes-from xrdp-native-audio \
    firefox

$DOCKER_COMMAND stop xrdp-native-audio

