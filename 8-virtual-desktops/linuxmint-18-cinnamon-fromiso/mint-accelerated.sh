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

# TODO I think this should use something like an XWayland window

# The X11 DISPLAY number of the nested Xephyr X server.
NESTED_DISPLAY=:2

IMAGE=linuxmint-cinnamon-fromiso:18
CONTAINER=mint-fromiso

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
        SRC=$(cat /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf | grep /lib/)

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

# Create .Xauthority.docker file with wildcarded hostname.
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
DOCKER_XAUTHORITY=${XAUTH}.docker
cp --preserve=all $XAUTH $DOCKER_XAUTHORITY
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTHORITY nmerge -

# Create initial /etc/passwd /etc/shadow /etc/group credentials if they
# don't already exist in this path. We use template files from a container
# spawned from the image we'll be using in the main run so that users and
# groups will be correct. If we copy from the host we may see problems if
# the host distro is different to the container distro, so don't do that.
# Note that the command below creates a new user and group in the cloned
# credentials files that match the user running this script.
if ! test -f "etc.tar.gz"; then
    echo "Creating /etc/passwd /etc/shadow and /etc/group for container."
    $DOCKER_COMMAND run --rm -it -v $PWD:/mnt $IMAGE \
        sh -c 'adduser --uid '$(id -u)' --no-create-home '$(id -un)'; usermod -aG sudo '$(id -un)'; tar zcf /mnt/etc.tar.gz -C / ./etc/passwd ./etc/shadow ./etc/group'
fi

# Create home directory
mkdir -p $(id -un)

# Launch Xephyr window.
$DOCKER_COMMAND run --rm -d \
    --ipc=host \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    xephyr $NESTED_DISPLAY -ac -reset -terminate 2> /dev/null

# Launch container as root to init core Linux services.
$DOCKER_COMMAND run --rm -d \
    --shm-size 2g \
    --security-opt apparmor=unconfined \
    --cap-add=SYS_ADMIN --cap-add=SYS_BOOT -v /sys/fs/cgroup:/sys/fs/cgroup \
    --name mint \
    -v $PWD/$(id -un):/home/$(id -un) \
    -e DISPLAY=unix$NESTED_DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    $IMAGE /sbin/init

# cp credentials bundle to container
cat etc.tar.gz | $DOCKER_COMMAND cp - $CONTAINER:/

# exec cinnamon-session as unprivileged user
$DOCKER_COMMAND exec -u $(id -u) mint cinnamon-session

