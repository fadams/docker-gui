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

BIN=$(cd $(dirname $0); echo ${PWD%docker-gui*})docker-gui/bin
. $BIN/docker-command.sh
. $BIN/docker-xauth.sh

IMAGE=debian-lxde-tightvnc:buster
CONTAINER=debian-tightvnc

# Create initial /etc/passwd /etc/shadow /etc/group
# credentials. We use template files from a container
# spawned from the image we'll be using in the main
# run so that users and groups will be correct.
# If we copy from the host we may see problems if the
# host distro is different to the container distro,
# so don't do that.
if ! test -f "etc.tar.gz"; then
    echo "Creating /etc/passwd /etc/shadow and /etc/group for container."
    $DOCKER_COMMAND run --rm -it \
        -v $PWD:/mnt \
        $IMAGE sh -c 'adduser --uid '$(id -u)' --no-create-home '$(id -un)'; usermod -aG sudo '$(id -un)'; tar zcf /mnt/etc.tar.gz -C / ./etc/passwd ./etc/shadow ./etc/group'
fi

# Create home directory
mkdir -p $(id -un)/.vnc

# Create VNC password if required.
if ! test -f "$(id -un)/.vnc/passwd"; then
    echo "creating VNC password"
    $DOCKER_COMMAND run --rm -it \
    -u $(id -u):$(id -g) \
    -v /etc/passwd:/etc/passwd:ro \
    -v $PWD/$(id -un):/home/$(id -un) \
    $IMAGE vncpasswd
fi

# Launch container as root to init core Linux services and
# launch the Display Manager and greeter. Switches to
# unprivileged user after login.
# --device=/dev/tty0 makes session creation cleaner.
# --ipc=host is set to allow Xephyr to use SHM XImages
$DOCKER_COMMAND run --rm -d \
    -p 5900:5900 \
    --device=/dev/tty0 \
    --name $CONTAINER \
    --ipc=host \
    --shm-size 2g \
    --security-opt apparmor=unconfined \
    --cap-add=SYS_ADMIN --cap-add=SYS_BOOT \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v $PWD/$(id -un)/.vnc:/tmp/lightdm/.vnc \
    -v $DOCKER_XAUTHORITY:/root/.Xauthority.docker:ro \
    -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:ro \
    $IMAGE /sbin/init

# Trivial wait for container to be running before cp credentials
sleep 0.25

# cp credentials bundle to container
cat etc.tar.gz | $DOCKER_COMMAND cp - $CONTAINER:/

