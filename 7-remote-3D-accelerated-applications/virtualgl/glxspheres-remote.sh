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

if [ -z ${REMOTE+x} ]; then
    echo "Usage: REMOTE=<display server container> ./glxspheres-remote.sh"
    echo "e.g. REMOTE=xserver-xspice ./glxspheres-remote.sh"
    exit 1
fi

BIN=$(cd $(dirname $0); echo ${PWD%docker-gui*})docker-gui/bin
. $BIN/docker-xauth.sh
. $BIN/docker-gpu.sh

# Launch glxspheres64. Use --volumes-from to mount /tmp/.X11-unix
# from REMOTE container and also use that container's IPC
$DOCKER_COMMAND run --rm \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    $X11_XAUTH \
    -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:ro \
    $GPU_FLAGS \
    -e DISPLAY=:1 \
    --ipc=container:$REMOTE \
    --volumes-from $REMOTE \
    virtualgl vglrun /opt/VirtualGL/bin/glxspheres64 $@

