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

if [ $# != 0 ] && ([ $1 == "-h" ] || [ $1 == "--help" ])
then 
    echo "Usage: x11-apps [COMMAND]"
    echo "A command to run a miscellaneous assortment of X applications that ship with the X Window System, including:"
    echo " - atobm, bitmap, and bmtoa, tools for manipulating bitmap images;"
    echo " - ico, a demo program animating polyhedrons;"
    echo " - oclock and xclock, graphical clocks;"
    echo " - rendercheck, a program to test render extension implementations;"
    echo " - transset, a tool to set opacity property on a window;"
    echo " - xbiff, a tool which tells you when you have new email;"
    echo " - xcalc, a scientific calculator desktop accessory;"
    echo " - xclipboard, a tool to manage cut-and-pasted text selections;"
    echo " - xconsole, which monitors system console messages;"
    echo " - xcursorgen, a tool for creating X cursor files from PNGs;"
    echo " - xditview, a viewer for ditroff output;"
    echo " - xedit, a simple text editor for X;"
    echo " - xeyes, a demo program in which a pair of eyes track the pointer;"
    echo " - xgc, a graphics demo;"
    echo " - xload, a monitor for the system load average;"
    echo " - xlogo, a demo program that displays the X logo;"
    echo " - xmag, which magnifies parts of the X screen;"
    echo " - xman, a manual page browser;"
    echo " - xmore, a text pager;"
    echo " - xwd, a utility for taking window dumps ("screenshots") of the X session;"
    echo " - xwud, a viewer for window dumps created by xwd;"
    echo " - Xmark, x11perf, and x11perfcomp, tools for benchmarking graphical
   operations under the X Window System;"
    exit 0
fi

# If user isn't in docker group prefix docker with sudo 
if id -nG $(id -un) | grep -qw docker; then
    DOCKER_COMMAND=docker
else
    DOCKER_COMMAND="sudo docker"
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
    x11-apps $@

