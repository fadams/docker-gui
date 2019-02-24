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

# Create initial /etc/passwd /etc/shadow /etc/group credentials.
# We use template files from a container spawned from the image we'll
# be using in the main run so that users and groups will be correct.
# If we copy from the host we may see problems if the host distro is
# different to the container distro, so don't do that.
$DOCKER_COMMAND run --rm -it \
    -v $PWD:/mnt \
    xrdp sh -c 'adduser --uid '$(id -u)' --no-create-home '$(id -un)'; usermod -aG sudo '$(id -un)'; tar zcf /mnt/etc.tar.gz -C / ./etc/passwd ./etc/shadow ./etc/group'

tar zxf etc.tar.gz
rm -f etc.tar.gz

