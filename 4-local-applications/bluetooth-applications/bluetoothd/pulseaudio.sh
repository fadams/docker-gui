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

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

# Add flags for connecting to the D-bus system bus.
DBUS_FLAGS="-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro "$DBUS_FLAGS

if test -f "/etc/apparmor.d/docker-dbus"; then
    APPARMOR_FLAGS="--security-opt apparmor:docker-dbus"
else
    APPARMOR_FLAGS="--security-opt apparmor=unconfined"
fi

# Unload module-bluetooth-discover from the host if present as the host and
# container can't both use the bluetooth speaker at the same time.
BLUETOOTH_DISCOVER=$(pactl list | grep module-bluetooth-discover)
if [ "${BLUETOOTH_DISCOVER}" != "" ]; then
    echo "pactl unload-module module-bluetooth-discover"
    pactl unload-module module-bluetooth-discover
fi

$DOCKER_COMMAND run --rm -it \
    $APPARMOR_FLAGS \
    $DBUS_FLAGS \
    -p 4714:4714 \
    pulseaudio | ./create-tunnel-sink.sh

if [ "${BLUETOOTH_DISCOVER}" != "" ]; then
    echo "pactl load-module module-bluetooth-discover"
    pactl load-module module-bluetooth-discover
fi
