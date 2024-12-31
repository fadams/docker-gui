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
# Run jackd2 in a container.
# jackd2 requires D-bus so this launch script integrates with the host's D-bus.
# For simplicity this example integrates with the host's shared memory namespace
# by bind-mounting /dev/shm and setting --ipc=host. A better option is probably
# to set --ipc=shareable here and use --ipc=container:<jackd2-mplayer's ID>
# in the client container.
# Sets the container realtime using --ulimit rtprio=99, this seems to be
# recognised OK by jackd.
################################################################################

# Replace with real device name
#ALSA_DEVICE=hw:CARD=NVidia,DEV=7

# Works for built in audio card
ALSA_DEVICE=hw:CARD=PCH,DEV=0

# This seems to work with VMWare VM Virtual Audio Device
#ALSA_DEVICE=hw:CARD=AudioPCI,DEV=1

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

if test -f "/etc/apparmor.d/docker-dbus"; then
    APPARMOR_FLAGS="--security-opt apparmor:docker-dbus"
else
    APPARMOR_FLAGS="--security-opt apparmor=unconfined"
fi

# Check is pasuspender (and therefore pulseaudio) is present, if so then
# prefix with pasuspender to suspend pulseaudio for the duration of the test.
if test -x /usr/bin/pulseaudio && test -x /usr/bin/pasuspender; then
    DOCKER_COMMAND="pasuspender -- "$DOCKER_COMMAND
fi

$DOCKER_COMMAND run --rm \
    --ulimit rtprio=99 \
    --ulimit memlock=83886080 \
    --ipc=host \
    --device=/dev/snd \
    --group-add $(cut -d: -f3 < <(getent group audio)) \
    $APPARMOR_FLAGS \
    $DBUS_FLAGS \
    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
    -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    jackd2-mplayer jackd -d alsa -d $ALSA_DEVICE -r 44100 -n 2 -p 2048

# VMWare VM Virtual Audio Device seems to need
# jackd2-mplayer jackd -d alsa -d $ALSA_DEVICE -r 44100 -n 2 -p 1024

