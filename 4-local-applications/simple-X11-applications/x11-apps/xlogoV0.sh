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
# the container. Although the X11 socket and DISPLAY have been correctly shared
# this example will fail because the X Client running in the container needs to
# authenticate with the X Server the user is running.
################################################################################

echo "This example should fail with the message:"
echo "No protocol specified"
echo "Error: Can't open display: unix:0"
echo
echo "This is because the X Client running in the container needs to authenticate"
echo "with the X Server the user is running."
echo
echo

docker run --rm \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    x11-apps

