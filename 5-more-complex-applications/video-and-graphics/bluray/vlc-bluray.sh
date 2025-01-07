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
. $BIN/docker-xauth.sh
. $BIN/docker-gpu.sh
. $BIN/docker-pulseaudio.sh
. $BIN/docker-dbus-all.sh

# Create a directory on the host that we can mount as a
# "home directory" in the container for the current user. 
mkdir -p $(id -un)/.config/pulse
mkdir -p $(id -un)/.config/dconf

# Create aacs config directory and copy keydb.cfg if it doesn't exist
# https://askubuntu.com/questions/140080/playing-blu-ray-using-vlc
mkdir -p $(id -un)/.config/aacs
if [ ! -f $(id -un)/.config/aacs/KEYDB.cfg ]; then
    #wget -O $(id -un)/.config/aacs/KEYDB.cfg http://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg

    # http://fvonline-db.bplaced.net/ has a larger more up to date database
    wget -O keydb_eng.zip http://fvonline-db.bplaced.net/fv_download.php?lang=eng
    unzip keydb_eng.zip
    mv keydb.cfg $(id -un)/.config/aacs/KEYDB.cfg
    rm keydb_eng.zip
fi

$DOCKER_COMMAND run --rm \
    --device=/dev/sr0 \
    --device=/dev/sg1 \
    --group-add $(cut -d: -f3 < <(getent group cdrom)) \
    -u $(id -u):$(id -g) \
    -v $PWD/$(id -un):/home/$(id -un) \
    -v /etc/passwd:/etc/passwd:ro \
    $APPARMOR_FLAGS \
    $DCONF_FLAGS \
    $PULSEAUDIO_FLAGS \
    $X11_FLAGS \
    $GPU_FLAGS \
    vlc-bluray

