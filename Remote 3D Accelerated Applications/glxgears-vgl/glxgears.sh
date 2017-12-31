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
# Script to run glxgears in a container.
# This script uses the simple approach of sharing the host's X11 socket and GPU
# device with the container. This method requires the container and GPU device
# to be on the same host, but it uses VirtualGL to perform “split rendering”
# (GLX forking) which intercepts GLX calls and renders to a memory buffer which
# can then be forwarded to a remote display.
# This script creates an additional .Xauthority file based on the user's but
# with a wildcard hostname to avoid having to set the container's hostname.
################################################################################

if test -c "/dev/nvidia-modeset"; then
    # Nvidia GPU
    DOCKER_COMMAND=nvidia-docker
    GPU_FLAGS="--device=/dev/nvidia-modeset -e LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}"
else
    DOCKER_COMMAND=docker
    if test -d "/var/lib/VBoxGuestAdditions"; then
        # VirtualBox GPU
        VBOXPATH=/usr/lib/x86_64-linux-gnu
        GPU_FLAGS="--device=/dev/vboxuser -v /var/lib/VBoxGuestAdditions/lib/libGL.so.1:$VBOXPATH/libGL.so.1"
        for f in $VBOXPATH/VBox*.so $VBOXPATH/libXcomposite.so.1
        do
            GPU_FLAGS="${GPU_FLAGS} -v $f:$f"
        done
    else
        # Default to Open Source Mesa GPU
        GPU_FLAGS="--device=/dev/dri"
    fi
fi

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
echo "ffff 0000  $(xauth nlist $DISPLAY | cut -d\  -f4-)" \
    | xauth -f $DOCKER_XAUTHORITY nmerge -

$DOCKER_COMMAND run --rm \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY \
    $GPU_FLAGS \
    glxgears-vgl

