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
. $BIN/docker-pulseaudio-all.sh
. $BIN/docker-dbus-all.sh

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/pulse
mkdir -p $(id -un)/.config/dconf

# Create password if required.
if ! test -f "$(id -un)/.vnc/passwd"; then
    echo "creating password"
    $(cd $(dirname $0); echo $PWD)/tigervnc-storepasswd.sh
fi

# Launch tigervncserver exposing /tmp/.X11-unix as a volume.
# Use -d option to daemonise and --init to run tini as pid 1
$DOCKER_COMMAND run --rm -it -d \
    --init \
    --shm-size 2g \
    --name=tigervnc \
    -p 5900:5900 \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=:1 \
    -e GEOMETRY=1280x720 \
    --ipc=shareable \
    tigervnc

# Launch firefox. Use --volumes-from to mount /tmp/.X11-unix
# from tigervnc and also use that container's IPC
$DOCKER_COMMAND run --rm \
    --shm-size 2g \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    $PULSEAUDIO_FLAGS \
    -e DISPLAY=:1 \
    --ipc=container:tigervnc \
    --volumes-from tigervnc \
    firefox

$DOCKER_COMMAND stop tigervnc
