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
# Run pacat in a container. Illustrates running a pulseaudio client example
# in a container and forwarding the audio via the pulseaudio socket to the host.
# This script uses the simple approach of sharing the host's pulse socket with
# the container. This method requires the container and pulse server to be on
# the same host as the pulse socket is a Unix domain socket bind-mounted in
# the container. 
################################################################################

docker run --rm -it \
    -u $(id -u):$(id -g) \
    -v $PWD/ok.wav:/home/$(id -un)/ok.wav:ro \
    -v /etc/passwd:/etc/passwd:ro \
    -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse \
    pulseaudio-utils paplay /home/$(id -un)/ok.wav
