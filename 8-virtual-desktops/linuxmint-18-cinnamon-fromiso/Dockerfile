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

FROM scratch

# Make sure APT operations are non-interactive
ENV DEBIAN_FRONTEND noninteractive

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

ADD linuxmint-18-cinnamon.tar.gz /

RUN \
    # Generate locales
    echo LANG=$LANG > /etc/default/locale && \
    update-locale LANG=$LANG && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure tzdata

#ENTRYPOINT ["/sbin/init"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t linuxmint-cinnamon-fromiso:18 .
