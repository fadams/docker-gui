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

# Replace with real device name
#ALSA_DEVICE=hw:CARD=NVidia,DEV=7

# Works for built in audio card
#ALSA_DEVICE=hw:CARD=PCH,DEV=0

# This seems to work with VMWare VM Virtual Audio Device
#ALSA_DEVICE=hw:CARD=AudioPCI,DEV=1

BIN=$(cd $(dirname $0); echo ${PWD%docker-gui*})docker-gui/bin
. $BIN/docker-xauth.sh
. $BIN/docker-gpu.sh
. $BIN/docker-jack.sh
. $BIN/docker-dbus-all.sh

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/dconf
$DOCKER_COMMAND run --rm \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    $JACKD_FLAGS \
    $X11_FLAGS \
    -e XDG_RUNTIME_DIR=/tmp/$(id -un) \
    $GPU_FLAGS \
    qjackctl $@

