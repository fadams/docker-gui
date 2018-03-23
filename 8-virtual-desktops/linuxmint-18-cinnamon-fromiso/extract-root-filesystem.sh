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

#DISTRIBUTION_ISO=linuxmint-18.2-cinnamon-64bit.iso
DISTRIBUTION_ISO=linuxmint-18.3-cinnamon-64bit.iso

# TODO use DISTRIBUTION_ISO to create tar file name
if [[ $DISTRIBUTION_ISO == *"linuxmint"* ]]; then
    # Linux Mint
    7z x $DISTRIBUTION_ISO -odistro
    sudo unsquashfs -f -d filesystem/ distro/casper/filesystem.squashfs
    sudo tar zcf linuxmint-18-cinnamon.tar.gz -C filesystem .
    sudo chown $(id -un):$(id -gn) linuxmint-18-cinnamon.tar.gz
    sudo rm -rf filesystem
    rm -rf distro
fi
