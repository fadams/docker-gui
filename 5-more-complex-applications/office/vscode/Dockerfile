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

# Visual Studio Code on Linux
#
# This Dockerfile builds the vscode Desktop IDE.
# That is to say the one you'd install by visiting:
# https://code.visualstudio.com/
# then downloading and installing the .deb from the web page link.
#
# The download URL used below was grokked from a manual download.
# https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/code_1.52.1-1608136922_amd64.deb

# Visual Studio Code allows for remote development in containers.
# The Visual Studio Code Remote Containers extension lets you use a Docker
# container as a full-featured development environment. It allows you to open
# any folder inside (or mounted into) a container and take advantage of Visual
# Studio Code's full feature set. A devcontainer.json file in your project
# tells VS Code how to access (or create) a development container with a
# well-defined tool and runtime stack. This container can be used to run an
# application or to sandbox tools, libraries, or runtimes needed for working
# with a codebase.
#
# https://code.visualstudio.com/docs/remote/containers
# https://code.visualstudio.com/docs/remote/containers-tutorial
# https://www.docker.com/blog/how-to-develop-inside-a-container-using-visual-studio-code-remote-containers/
#
# Note that the above tutorials assume vscode IDE is installed on desktop
# not in a container, so the instruction "Once the process starts, navigate
# to http://localhost:3000 and you should see the simple Node.js server
# running!" will fail. To resolve this use the IP of either the
# vsc-vscode-remote... container or the vscode container itself e.g. via
# docker inspect --format '{{ .NetworkSettings.IPAddress }}' container_name_or_id
# Alternatively, launch the container in the host's network namespace
# by adding --network=host to the launch script.
#
# To enable this capability we install the docker CLI in this image
# and bind-mount the docker socket in the container.

FROM debian:bullseye-slim

# Install vscode Desktop IDE
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used
    apt-get install -y --no-install-recommends \
	apt-transport-https wget gnupg ca-certificates \
    libgl1-mesa-glx libgl1-mesa-dri \
    libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 \
    libxss1 libgbm1 libx11-xcb1 libxcb-dri3-0 \
    libxtst6 libasound2 pulseaudio librsvg2-common \
    fonts-symbola fonts-lmodern fonts-freefont-ttf \
    fonts-liberation fonts-dejavu gsfonts git && \
    # Download and install vscode.
    VERSION=code_1.52.1-1608136922 && \
    PACKAGE=${VERSION}_amd64.deb && \
    DOWNLOAD_URL=https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/${PACKAGE} && \
    wget -O ${PACKAGE} ${DOWNLOAD_URL} && \
    dpkg -i ${PACKAGE} && rm ${PACKAGE} && \
    #---------------------------------------------------------------------------
    # Adding Docker CLI to enable vscode remote development
    # in containers feature. Remove this block if support for
    # this feaure is not required.
    # Add Docker’s official GPG key:
    wget -O /usr/share/keyrings/docker-archive.key \
            https://download.docker.com/linux/debian/gpg && \
    # Add Docker repository. Note we're using buster here
    # as bullseye repo isn't yet available.
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive.key] https://download.docker.com/linux/debian buster stable main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install docker-ce-cli && \
    #---------------------------------------------------------------------------
	rm -rf /var/lib/apt/lists/* && \
    cp /etc/pulse/client.conf \
       /etc/pulse/client-noshm.conf && \
    sed -i "s/; enable-shm = yes/enable-shm = no/g" \
        /etc/pulse/client-noshm.conf

# Use -w (Wait for the files to be closed before returning) option
# otherwise /usr/bin/code returns, immediately causing the container to exit.
ENTRYPOINT ["/usr/bin/code", "-w"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t vscode .
# 

