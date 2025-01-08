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

#FROM debian:stretch-slim # Deprecated
FROM ubuntu:24.04

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

# http://remarkableapp.github.io/files/remarkable_1.87_all.deb
# https://remarkableapp.github.io/files/remarkable_1.95.deb

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl ca-certificates locales tzdata python3 \
    python3-all python3-setuptools python3-bs4 python3-gi \
    python3-gtkspellcheck python3-markdown librsvg2-common \
    dconf-gsettings-backend yelp wkhtmltopdf \
    gir1.2-glib-2.0 gir1.2-webkit2-4.1 \
    gir1.2-gtk-3.0 gir1.2-gtksource-3.0 \
    fonts-symbola fonts-lmodern fonts-freefont-ttf \
    fonts-liberation fonts-dejavu ttf-mscorefonts-installer \
    # No libgl1-mesa-glx in ubuntu:24.04, explicitly install libglx-mesa0 libgl1
	mesa-utils libglx-mesa0 libgl1 libgl1-mesa-dri && \
    # Download and install remarkable
    curl -sSL https://remarkableapp.github.io/files/remarkable_1.95.deb -o remarkable_1.95.deb && \
    dpkg -i remarkable_1.95.deb && \
    # Tidy up packages only used for installing remarkable.
    rm remarkable_1.95.deb && \
    apt-get clean && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && \
    locale-gen && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure tzdata

ENTRYPOINT ["remarkable"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t remarkable .
#

