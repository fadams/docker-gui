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
# This script uses the simple approach of sharing the host's X11 socket with
# the container. This method requires the container and display to be on the
# same host, but gives performance that is equivalent to running the application
# directly (i.e. not in a container) on the host.
# This script creates an additional .Xauthority file based on the user's but
# with a wildcard hostname to avoid having to set the container's hostname.
# This script uses the -u option of docker run to reduce the privileges of the
# container to that of the user running the script, bind mounting /etc/passwd
# read only isn't strictly necessary but allows the container to map the user's
# ID to name to avoid seeing "I have no name!" when launching a shell.
################################################################################

DOCKER_COMMAND=docker
DST=/usr/lib/x86_64-linux-gnu
if test -c "/dev/nvidia-modeset"; then
    # Nvidia GPU
    if test -f "/usr/bin/nvidia-container-runtime"; then
        # Nvidia Docker Version 2
        # See https://github.com/NVIDIA/nvidia-container-runtime.

        # Attempt to find the actual Nvidia library path. It should be
        # something like /usr/lib/nvidia-<driver version>
        SRC=$(cat /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf | grep /lib/)

        GPU_FLAGS="--runtime=nvidia "
        GPU_FLAGS+="--device=/dev/nvidia-modeset "
        GPU_FLAGS+="-e NVIDIA_VISIBLE_DEVICES=all "
        GPU_FLAGS+="-e NVIDIA_DRIVER_CAPABILITIES=graphics "
        GPU_FLAGS+="-v $SRC/libGL.so.1:$DST/libGL.so.1:ro "
        GPU_FLAGS+="-v $SRC/libGLX.so.0:$DST/libGLX.so.0:ro "
        GPU_FLAGS+="-v $SRC/libGLdispatch.so.0:$DST/libGLdispatch.so.0:ro "
    else
        # Nvidia Docker Version 1
        echo "This script is specifically intended to illustrate nvidia-docker V2"
        echo "You appear to have nvidia-docker V1 installed, try glxgearsV1.sh."
        exit 1
    fi
else
    echo "This version of the glxgears launch script is Nvidia specific."
    exit 1
fi

# If user isn't in docker group prefix docker with sudo 
if ! (id -nG $(id -un) | grep -qw docker); then
    DOCKER_COMMAND="sudo $DOCKER_COMMAND"
fi

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

$DOCKER_COMMAND run --rm \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    $GPU_FLAGS \
    glxgears

