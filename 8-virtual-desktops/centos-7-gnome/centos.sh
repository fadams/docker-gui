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


# TODO eventually remove the stuff below when problems are fixed.
#     -v $PWD/$(id -un)/home/$(id -un) \
#     $GPU_FLAGS \
#    --cap-add=SYS_ADMIN --cap-add=SYS_BOOT -v /sys/fs/cgroup:/sys/fs/cgroup \
#--net=host \
#--ipc=host \

# Adding these causes systemd to go haywire with errors:
# systemd[1]: Looping too fast. Throttling execution a little.
# errors when running journalctl and excess systemd CPU usage observed with top
# I think that the issue is permission related, I think D-bus crashes as it
# needs a dbus user in centos.
#    -v /etc/passwd:/etc/passwd:ro \
#    -v /etc/shadow:/etc/shadow:ro \
#    -v /etc/group:/etc/group:ro \

#install-info: No such file or directory for /usr/share/info/which.info.gz
#install-info: No such file or directory for /usr/share/info/nettle.info
#install-info: No such file or directory for /usr/share/info/libchewing.info
#install-info: No such file or directory for /usr/share/info/liblouis.info
#warning: /etc/yum/pluginconf.d/langpacks.conf created as /etc/yum/pluginconf.d/#langpacks.conf.rpmnew
#install-info: No such file or directory for /usr/share/info/accounting.info







# Create initial /etc/passwd /etc/shadow /etc/group credentials if they
# don't already exist in this path. We use template files from a container
# spawned from the image we'll be using in the main run so that users and
# groups will be correct, if we copy from the host we may see problems if
# the host distro is different to the container distro so don't do that.
# Note that the command below creates a new user and group in the cloned
# credentials files that match the user running this script.
if ! test -d "etc"; then
    echo "Creating /etc/passwd /etc/shadow /etc/group"
    $DOCKER_COMMAND run --rm centos-gnome:7.4 \
        sh -c 'groupadd -r -g '$(id -g)' '$(id -un)'; useradd -u '$(id -u)' -r -g '$(id -gn)' '$(id -un)'; tar c -C / ./etc/passwd ./etc/shadow ./etc/group' | tar xv
fi

# Create home directory
mkdir -p $(id -un)

# Launch Xephyr window on display :3 to launch the desktop.
if test -c "/dev/nvidia-modeset"; then
    # For systems with Nvidia Drivers explicitly preload
    # software renderer, for mesa it's done automatically.
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libGL.so \
    Xephyr -ac -reset -terminate 2> /dev/null :3 &
else
    Xephyr -ac -reset -terminate 2> /dev/null :3 &
fi

# Launch container as root to init core Linux services.
$DOCKER_COMMAND run --rm -d \
    --cap-add=SYS_ADMIN --cap-add=SYS_BOOT -v /sys/fs/cgroup:/sys/fs/cgroup \
    --name centos \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v $PWD/etc/passwd:/etc/passwd \
    -v $PWD/etc/shadow:/etc/shadow \
    -v $PWD/etc/group:/etc/group \
    -e DISPLAY=unix:3.0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e XAUTHORITY=$DOCKER_XAUTHORITY \
    -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
    centos-gnome:7.4 /sbin/init

# exec gnome-session as unprivileged user
$DOCKER_COMMAND exec -u $(id -u) centos gnome-session

