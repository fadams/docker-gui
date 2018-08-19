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

# This script receives the output piped from the docker pulseaudio container,
# which is the output from the set-a2dp-sink.sh script run by the container.
#
# Each line of stdin is parsed looking for "a2dp_sink" and when it sees this
# pactl load-module module-tunnel-sink server=localhost:4714 sink_name=bluetooth
# is called to create a bridge between the PulseAudio server running in the
# host and the one running on the container. This allows the host to use a
# bluetooth audio sink running in the container as if it were a local sink.
while IFS= read -r line; do
    echo ${line}
    if [[ $line = *"a2dp_sink"* ]]; then
        sleep 1
        echo "Connecting module-tunnel-sink to localhost:4714"
        echo -e "\r"
        pactl load-module module-tunnel-sink server=localhost:4714 sink_name=bluetooth > /dev/null
    fi
done
