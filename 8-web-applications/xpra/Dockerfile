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

FROM xpra

# Install xpra-html5
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl libjs-jquery-ui && \
    XPRA_VERSION=3.0.5-r24939-1 && \
    XPRA=https://xpra.org/dists/stretch/main/binary-amd64 && \
    echo "XPRA_VERSION version: ${XPRA_VERSION}" && \
    curl -sSL ${XPRA}/xpra-html5_${XPRA_VERSION}_amd64.deb \
         -o xpra-html5_${XPRA_VERSION}_amd64.deb && \
    dpkg -i xpra-html5_${XPRA_VERSION}_amd64.deb && \
    # Create simple launch scripts to start xpra server
    # Note dbus-launch was made the default in 2.5
    # and causes issues if D-bus isn't present, so set
    # --dbus-launch= for now. TODO investigate the best way
    # to integrate the xpra server container with D-bus.
    echo '#!/bin/bash\nmkdir -p $XDG_RUNTIME_DIR/pulse\nmkdir -p ~/.xpra\nexec xpra start --daemon=no --notifications=no $DISPLAY --dbus-launch= --html=on $@\n' > /usr/local/bin/start && \
    chmod +x /usr/local/bin/start && \
    # Tidy up
    rm xpra-html5_${XPRA_VERSION}_amd64.deb && \
    apt-get clean && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t xpra-html5 .
#

