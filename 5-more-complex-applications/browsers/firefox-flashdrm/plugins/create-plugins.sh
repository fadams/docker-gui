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

# Extract the libfreshwrapper-flashplayer.so wrapper plugin
# built by the build-libfreshwrapper container.
$DOCKER_COMMAND run --rm build-libfreshwrapper cat /src/libfreshwrapper-flashplayer.so > libfreshwrapper-flashplayer.so

# Extract libpepflashplayer.so and manifest.json created by pulling
# the Chrome OS recovery image and unpacking it.
$DOCKER_COMMAND run --rm extract-libpepflashplayer cat /mnt/pepper/libpepflashplayer.so > libpepflashplayer.so

$DOCKER_COMMAND run --rm extract-libpepflashplayer cat /mnt/pepper/manifest.json > manifest.json

