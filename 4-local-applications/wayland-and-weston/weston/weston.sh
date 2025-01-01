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

# Attempt to detect the type of GPU present on the host and set the necessary
# parameters for docker run in the GPU_FLAGS variable.
DOCKER_COMMAND=docker
DST=/usr/lib/x86_64-linux-gnu
if test -c "/dev/nvidia-modeset"; then
  # Nvidia GPU
  GPU_FLAGS="--device=/dev/nvidia-modeset "
  if test -f "/usr/bin/nvidia-container-runtime"; then
    # Nvidia Docker Version 2 or nvidia-container-toolkit
    # See https://github.com/NVIDIA/nvidia-container-runtime.
    # https://github.com/NVIDIA/nvidia-container-toolkit
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html#specialized-configurations-with-docker

    # Attempt to find the actual Nvidia library path. It should be
    # something like /usr/lib/nvidia-<driver version>
    #SRC=/usr/lib/x86_64-linux-gnu
    #if test -f "/etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf"; then
    #  SRC=$(cat /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf | grep /lib/)
    #fi

    GPU_FLAGS+="--runtime=nvidia "
    GPU_FLAGS+="-e NVIDIA_VISIBLE_DEVICES=all "
    GPU_FLAGS+="-e NVIDIA_DRIVER_CAPABILITIES=graphics,video "

    # Previous version using Nvidia Docker Version 2 needed to mount
    # libraries nvidia-container-toolkit doesn't seem to need that.
    # Weirdly though that seems to need graphics,video not just graphics???
    #GPU_FLAGS+="-e NVIDIA_DRIVER_CAPABILITIES=graphics "
    #GPU_FLAGS+="-v $SRC/libGL.so.1:$DST/libGL.so.1:ro "
    #GPU_FLAGS+="-v $SRC/libGLX.so.0:$DST/libGLX.so.0:ro "
    #GPU_FLAGS+="-v $SRC/libGLdispatch.so.0:$DST/libGLdispatch.so.0:ro "
    #GPU_FLAGS+="-v $SRC/libEGL.so.1:$DST/libEGL.so.1:ro "
    #GPU_FLAGS+="-v $SRC/libGLESv1_CM.so.1:$DST/libGLESv1_CM.so.1:ro "
    #GPU_FLAGS+="-v $SRC/libGLESv2.so.2:$DST/libGLESv2.so.2:ro "
  else
    # Nvidia Docker Version 1
    echo "Nvidia Docker Version 1 not supported"
    exit 1
    #DOCKER_COMMAND=nvidia-docker
    #SRC=/usr/local/nvidia
    #GPU_FLAGS+="-e LD_LIBRARY_PATH=$SRC/lib:$SRC/lib64:${LD_LIBRARY_PATH} "
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

# The -Swayland-0 starts weston on wayland-0. It used to do that by default
# but that behaviour changed to default to wayland-1 as per
# https://gitlab.freedesktop.org/wayland/weston/-/merge_requests/486
$DOCKER_COMMAND run --rm \
  --ipc=host \
  -u $(id -u):$(id -g) \
  -v /etc/passwd:/etc/passwd:ro \
  -e DISPLAY=unix$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /tmp/.X0-lock:/tmp/.X0-lock \
  -e XAUTHORITY=$DOCKER_XAUTHORITY \
  -v $DOCKER_XAUTHORITY:$DOCKER_XAUTHORITY:ro \
  -e XDG_RUNTIME_DIR=/tmp \
  -v $XDG_RUNTIME_DIR:/tmp \
  $GPU_FLAGS \
  weston -Swayland-0

