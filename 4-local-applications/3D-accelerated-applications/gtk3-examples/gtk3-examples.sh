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
# This script uses the -u option of docker run to reduce the priviledges of the
# container to that of the user running the script, bind mounting /etc/passwd
# read only isn't strictly necessary but allows the container to map the user's
# ID to name to avoid seeing "I have no name!" when launching a shell.
#
# In this script we have added configuration so that the container will work
# properly with dconf/D-bus:
#    --net host \
#    -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
#    -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
################################################################################

if [ $# != 0 ] && ([ $1 == "-h" ] || [ $1 == "--help" ])
then 
    echo "Usage: gtk3-examples [COMMAND]"
    echo "Example files and demonstration programs for GTK+3, including:"
    echo " - gtk3-demo"
    echo " - gtk3-demo-application"
    echo " - gtk3-icon-browser"
    echo " - gtk3-widget-factory"
    exit 0
fi

# Attempt to detect the type of GPU present on the host and set the necessary
# parameters for docker run in the GPU_FLAGS variable.
DOCKER_COMMAND=docker
DST=/usr/lib/x86_64-linux-gnu
if test -c "/dev/nvidia-modeset"; then
    # Nvidia GPU
    GPU_FLAGS="--device=/dev/nvidia-modeset "
    if test -f "/usr/bin/nvidia-container-runtime"; then
        # Nvidia Docker Version 2
        # See https://github.com/NVIDIA/nvidia-container-runtime.

        # Attempt to find the actual Nvidia library path. It should be
        # something like /usr/lib/nvidia-<driver version>
        SRC=/usr/lib/x86_64-linux-gnu
        if test -f "/etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf"; then
            SRC=$(cat /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf | grep /lib/)
        fi

        GPU_FLAGS+="--runtime=nvidia "
        GPU_FLAGS+="-e NVIDIA_VISIBLE_DEVICES=all "
        GPU_FLAGS+="-e NVIDIA_DRIVER_CAPABILITIES=graphics "
        GPU_FLAGS+="-v $SRC/libGL.so.1:$DST/libGL.so.1:ro "
        GPU_FLAGS+="-v $SRC/libGLX.so.0:$DST/libGLX.so.0:ro "
        GPU_FLAGS+="-v $SRC/libGLdispatch.so.0:$DST/libGLdispatch.so.0:ro "
    else
        # Nvidia Docker Version 1
        DOCKER_COMMAND=nvidia-docker
        SRC=/usr/local/nvidia
        GPU_FLAGS+="-e LD_LIBRARY_PATH=$SRC/lib:$SRC/lib64:${LD_LIBRARY_PATH} "
    fi
else
    # Non-Nvidia GPU path
    if test -d "/var/lib/VBoxGuestAdditions"; then
        # VirtualBox GPU
        GPU_FLAGS="--device=/dev/vboxuser "
        GPU_FLAGS+="-v /var/lib/VBoxGuestAdditions/lib/libGL.so.1:$DST/libGL.so.1 "
        for f in $DST/VBox*.so $DST/libXcomposite.so.1
        do
            GPU_FLAGS+="-v $f:$f "
        done
    else
        # Open Source Mesa GPU.
        GPU_FLAGS="--device=/dev/dri "
        # Adding video group's gid seems more reliable than adding by name.
        GPU_FLAGS+="--group-add $(cut -d: -f3 < <(getent group video)) "
    fi
fi

# If user isn't in docker group prefix docker with sudo 
if ! (id -nG $(id -un) | grep -qw docker); then
    DOCKER_COMMAND="sudo $DOCKER_COMMAND"
fi

if [[ $DBUS_SESSION_BUS_ADDRESS == *"abstract"* ]]; then
    DBUS_FLAGS="--net=host"
else
    DBUS_FLAGS="-v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro -e NO_AT_BRIDGE=1"
fi

# Set appropriate apparmor flags.
if test -f "/etc/apparmor.d/docker-dbus"; then
    APPARMOR_FLAGS="--security-opt apparmor:docker-dbus"
else
    APPARMOR_FLAGS="--security-opt apparmor=unconfined"
fi

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/dconf
$DOCKER_COMMAND run --rm \
    $APPARMOR_FLAGS \
    $DBUS_FLAGS \
   -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
   -v $HOME/.config/dconf/user:$HOME/.config/dconf/user:ro \
   -u $(id -u):$(id -g) \
   -v $PWD/$(id -un):/home/$(id -un) \
   -v /etc/passwd:/etc/passwd:ro \
   -e DISPLAY=unix$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
   -e XAUTHORITY=$DOCKER_XAUTHORITY \
   -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    $GPU_FLAGS \
    gtk-3-examples $@

