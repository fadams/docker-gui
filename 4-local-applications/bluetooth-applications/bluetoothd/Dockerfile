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

FROM debian:stretch-slim

# Install bluetoothd and pulseaudio
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used
    apt-get install -y --no-install-recommends \
    bluez pulseaudio pulseaudio-module-bluetooth pulseaudio-utils && \
	rm -rf /var/lib/apt/lists/* && \
    sed -i "s/; exit-idle-time = 20/exit-idle-time = -1/g" /etc/pulse/daemon.conf && \
    sed -i "s/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1\;192.168.0.0\/16 port=4714/g" /etc/pulse/default.pa

COPY ./set-a2dp-sink.sh /src/set-a2dp-sink.sh
COPY ./startup.sh /src/startup.sh

ENTRYPOINT ["/src/startup.sh"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t bluetoothd .


