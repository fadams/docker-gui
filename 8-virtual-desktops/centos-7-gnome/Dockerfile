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

FROM centos:7.4.1708

RUN \
    # When installing from yum repo it is common to see:
    # Error : Public key for *.rpm is not installed
    # This can be resolved by importing the public key files for RPM
    # which may be found by running the following command
    # docker run --rm centos:7.4.1708 find / -name *GPG*
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Testing-7 && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7 && \
    # Install required packages
    yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs groups install "GNOME Desktop" || true

#ENTRYPOINT ["/sbin/init"]

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t centos-gnome:7.4 .

# FIXME
#install-info: No such file or directory for /usr/share/info/which.info.gz
#install-info: No such file or directory for /usr/share/info/nettle.info
#install-info: No such file or directory for /usr/share/info/libchewing.info
#install-info: No such file or directory for /usr/share/info/liblouis.info
#warning: /etc/yum/pluginconf.d/langpacks.conf created as /etc/yum/pluginconf.d/#langpacks.conf.rpmnew
#install-info: No such file or directory for /usr/share/info/accounting.info
