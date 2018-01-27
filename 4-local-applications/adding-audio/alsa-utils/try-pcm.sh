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
# Run a script in a container that iterates through every ALSA PCM device and
# attempts to play a simple wav on each device to see which makes a sound.
# With ALSA there are often *many* devices available and it can often be a
# bit of a mystery trying to work out which one is actually connected to
# the speakers because the enumeration can often be a bit cryptic.
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
    --device=/dev/snd \
    --group-add $(cut -d: -f3 < <(getent group audio)) \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -v $PWD/ok.wav:$HOME/ok.wav:ro \
    alsa-utils
