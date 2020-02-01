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

# Install x2goclient.
# Note that x2goclient needs xauth and fails to connect
# in a fairly hard to diagnose way without it.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates gnupg dirmngr xauth \
    openssh-sftp-server openssh-server \
    libgl1-mesa-glx libgl1-mesa-dri && \
    # Set up the repositories for x2go
    echo "deb http://packages.x2go.org/debian stretch extras main\n" > /etc/apt/sources.list.d/x2go.list && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 E1F958385BFE2B6E && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    x2goclient && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["x2goclient"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t x2goclient .
#

