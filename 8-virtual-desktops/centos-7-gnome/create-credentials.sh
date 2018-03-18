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


if ! test -d "etc"; then
    echo "Creating /etc/passwd /etc/shadow /etc/group"
    docker run --rm centos-gnome:7.4 \
        sh -c 'groupadd -r -g '$(id -g)' '$(id -un)'; useradd -u '$(id -u)' -r -g '$(id -gn)' '$(id -un)'; tar c -C / ./etc/passwd ./etc/shadow ./etc/group' | tar xv
fi
