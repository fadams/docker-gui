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

# This script receives the verbose output from pulseaudio piped via
# pulseaudio -v 2>&1 | /src/set-a2dp-sink.sh
# When an A2DP sink connects pulseaudio generates a log line containing the
# text "[pulseaudio] card.c: Created", if we see that we regex extract the
# bluez_card name also present in that log line which can be used in the
# pacmd call to set the profile to a2dp_sink.
while IFS= read -r line; do
    if [[ $line = *"[pulseaudio] card.c: Created"* ]]; then
        NAME=$(echo "${line}" | grep -o -E "bluez_card.([[:xdigit:]]{2}_){5}[[:xdigit:]]{2}")
        echo "pacmd set-card-profile ${NAME} a2dp_sink"
        pacmd set-card-profile ${NAME} a2dp_sink
    fi
done
