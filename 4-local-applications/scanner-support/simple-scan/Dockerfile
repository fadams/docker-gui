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

# Install simple-scan
# librsvg2-common fixes the warning message: Could not load a pixbuf
# from /org/gtk/libgtk/theme/Adwaita/assets/bullet-symbolic.svg.
# This may indicate that pixbuf loaders or the mime database could
# not be found and some graphics/icons fail to load.
# Note that moving to ubuntu:24.04 gives libEGL not available and
# GskVulkanRenderer warnings. I *think* this might be to do with moving to
# GTK4. Adding libglx-mesa0 libgl1 libgl1-mesa-dri fixes those warnings.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used
    apt-get install -y --no-install-recommends \
    # No libgl1-mesa-glx in ubuntu:24.04, explicitly install libglx-mesa0 libgl1
	librsvg2-common libglx-mesa0 libgl1 libgl1-mesa-dri \
    libcanberra-gtk3-module simple-scan && \
	rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["simple-scan"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t simple-scan .


