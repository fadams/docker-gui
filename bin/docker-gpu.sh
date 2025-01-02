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
# This script exports the various volumes and environment variables required
# by docker run in order to use GPU 3D acceleration. The script detects the GPU
# "family" with support for Nvidia, Mesa and VirtualBox, though the latter is
# a somewhat limited Virtual GPU. The script exports the required information in
# the GPU_FLAGS environment variable. This script also checks whether the user
# is in the docker group, if so then DOCKER_COMMAND is set to "docker" otherwise
# it is set to "sudo docker". N.B. use this script in place of docker-command.sh
# as this script may also set DOCKER_COMMAND as Nvidia Docker Version 1 used
# the command nvidia-docker rather than docker.
################################################################################

DOCKER_COMMAND=docker
DST=/usr/lib/x86_64-linux-gnu
if test -c "/dev/nvidia-modeset"; then
    # Nvidia GPU
    GPU_FLAGS="--device=/dev/nvidia-modeset "
    # Nvidia Docker Version 2 or nvidia-container-toolkit
    # See https://github.com/NVIDIA/nvidia-container-runtime.
    # https://github.com/NVIDIA/nvidia-container-toolkit
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html#specialized-configurations-with-docker

    GPU_FLAGS+="--runtime=nvidia "
    GPU_FLAGS+="-e NVIDIA_VISIBLE_DEVICES=all "
    GPU_FLAGS+="-e NVIDIA_DRIVER_CAPABILITIES=all "
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
GPU_FLAGS+="-v $DST/vdpau:$DST/vdpau:ro "

# If user isn't in docker group prefix docker with sudo 
if ! (id -nG $(id -un) | grep -qw docker); then
    DOCKER_COMMAND="sudo $DOCKER_COMMAND"
fi

