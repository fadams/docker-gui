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
# the container and using xhost to grant the container access to the X Server.
# This method requires the container and display to be on the same host, but
# gives performance that is equivalent to running the application directly
# (i.e. not in a container) on the host.
################################################################################

xhost +local: # Add non-network local connections to the X Server ACL.
docker run --rm \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    x11-apps
xhost -local: # Remove non-network local connections from the X Server ACL.

