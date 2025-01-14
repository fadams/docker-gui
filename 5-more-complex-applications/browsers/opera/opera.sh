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

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/pulse
mkdir -p $(id -un)/.config/dconf

# The default Docker seccomp profile defined at:
# https://github.com/moby/moby/blob/master/profiles/seccomp/default.json
# requires CAP_SYS_ADMIN to run clone with the CLONE_NEWUSER flag
# in other words CAP_SYS_ADMIN is needed for a process in a container
# to be able to create user namespaces (used by the Opera sandbox).
# The seccomp-enable-clone.json profile minimally changes the default
# profile to allow "clone" and "unshare". Using a modified seccomp
# seems a better approach than --cap-add SYS_ADMIN or launching Opera
# with --no-sandbox especially as from Linux 3.8, unprivileged processes
# can create user namespaces.
$DOCKER_COMMAND run --rm \
    --security-opt seccomp=$PWD/seccomp-enable-clone.json \
    --shm-size 2g \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    -e XDG_RUNTIME_DIR=/tmp/$(id -un) \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    $PULSEAUDIO_FLAGS \
    $X11_FLAGS \
    $GPU_FLAGS \
    opera

