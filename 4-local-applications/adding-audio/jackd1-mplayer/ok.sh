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
# Run mplayer in a container.
# For simplicity this example integrates with the host's shared memory namespace
# by bind-mounting /dev/shm and setting --ipc=host. A better option is probably
# to use --ipc=container:<jackd1-mplayer's ID> in the client container.
# Sets the container realtime using --ulimit rtprio=99, this seems to be
# recognised OK by jackd.
################################################################################

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
fi

# Check is pasuspender (and therefore pulseaudio) is present, if so then
# prefix with pasuspender to suspend pulseaudio for the duration of the test.
if test -f /usr/bin/pasuspender; then
    DOCKER_COMMAND="pasuspender -- "$DOCKER_COMMAND
fi

$DOCKER_COMMAND run --rm \
    --ulimit rtprio=99 \
    --ipc=host \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -v /dev/shm:/dev/shm \
    -v $PWD/ok.wav:$HOME/ok.wav:ro \
    jackd1-mplayer mplayer -ao jack $HOME/ok.wav

