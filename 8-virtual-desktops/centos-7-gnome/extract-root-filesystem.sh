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

DISTRIBUTION_ISO=CentOS-7-x86_64-DVD-1708.iso

# TODO use DISTRIBUTION_ISO to create tar file name
if [[ $DISTRIBUTION_ISO == *"CentOS"* ]]; then
    # CentOS
    echo CentOS
    7z x $DISTRIBUTION_ISO -odistro
    unsquashfs -f -d rootfs/ distro/LiveOS/squashfs.img
    mkdir filesystem
    sudo mount rootfs/LiveOS/rootfs.img filesystem
    sudo cp distro/Packages/yum-3.4.3-154.el7.centos.noarch.rpm filesystem/var/cache/yum
    sudo tar zcf centos-7-rootfs.tar.gz -C filesystem .
    sudo chown $(id -un):$(id -gn) centos-7-rootfs.tar.gz
    sudo umount filesystem
    rmdir filesystem
    rm -rf rootfs
    rm -rf distro
fi
