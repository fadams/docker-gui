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
# Run pacat in a container. Illustrates running a pulseaudio client in a
# container and forwarding the audio via the pulseaudio socket to a remote host.
#
# This script gets the remote (to the container) host's IP from the SSH_CLIENT
# environment variable. The ssh client is the host that is local to the user
# and therefore running the desktop audio server.
#
# N.B. for this mechanism to work the script needs to be launched via ssh
# in order for the SSH_CLIENT variable to be automatically set, though if this
# variable is set in the environment by some other means it should work too e.g.
# SSH_CLIENT=<PA-daemon-IP> ./remote-noise.sh
# would also work.
#
# Another requirement is for the host running the daemon to have
# module-native-protocol-tcp installed and enabled either via paprefs or in
# /etc/pulse/default.pa (or ~/.config/pulse/default.pa)
# load-module module-native-protocol-tcp \
# auth-ip-acl=127.0.0.1;172.17.0.0/16;192.168.0.0/16 port=4713
################################################################################

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

# Get the ssh client IP so we know where to send the audio.
PA_HOST=$(echo ${SSH_CLIENT%% *})

if [ -z $PA_HOST ]; then
    echo "This example needs to be launched via ssh to work."
else
    echo "PULSE_SERVER=$PA_HOST:4713"
    $DOCKER_COMMAND run --rm \
        -u $(id -u):$(id -g) \
        -v /etc/passwd:/etc/passwd:ro \
        -e PULSE_SERVER=$PA_HOST:4713 \
        pulseaudio-utils
fi
