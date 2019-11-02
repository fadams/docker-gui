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

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user.
mkdir -p $(id -un)/.guacamole

# Create user-mapping.xml if required.
if ! test -f "$(id -un)/.guacamole/user-mapping.xml"; then
    read -p "Enter remote VNC host name: " vnchost
    echo
    read -p "Enter remote RDP host name: " rdphost
    echo
    echo "creating password"
    read -s -p "Enter password: " password
    echo
    read -s -p "Confirm password: " confirmation
    echo
    if [ $confirmation != $password ]; then
        echo "Confirmation doesn't match password, exiting!"
        exit 1
    fi

    echo -e "<user-mapping>\n  <!-- Per-user authentication and config information -->\n  <authorize username=\"$(id -un)\" password=\"$password\">\n    <connection name=\"VNC\">\n      <protocol>vnc</protocol>\n      <param name=\"hostname\">$vnchost</param>\n      <param name=\"port\">5900</param>\n      <param name=\"password\">$password</param>\n    </connection>\n\n    <connection name=\"RDP\">\n      <protocol>rdp</protocol>\n      <param name=\"hostname\">$rdphost</param>\n      <param name=\"port\">3389</param>\n      <param name=\"password\">$password</param>\n    </connection>\n  </authorize>\n\n</user-mapping>" > $(id -un)/.guacamole/user-mapping.xml

fi

# Use --init to run tini as pid 1.
$DOCKER_COMMAND run --rm -it \
    --init \
    -p 8080:8080 \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    guacamole

