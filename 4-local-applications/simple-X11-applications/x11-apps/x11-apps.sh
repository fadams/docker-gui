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
# This image uses the simple approach of sharing the host's X11 socket with
# the container and using xhost to grant the container access to the X Server.
# This method requires the container and display to be on the same host, but
# gives performance that is equivalent to running the application directly
# (i.e. not in a container) on the host.
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

xhost +local:root # Add local:root to the X Server access list.
docker run --rm \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    x11-apps $@
xhost -local:root # Remove local:root to the X Server access list.
