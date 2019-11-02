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

# git clone and build guacd
RUN mkdir -p /usr/share/man/man1 && mkdir -p /usr/share/man/man7 && \
    apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
	git autoconf automake gcc libcairo2-dev libfreerdp-dev libjpeg62-turbo-dev \
    libossp-uuid-dev libpango1.0-dev libpulse-dev libssh2-1-dev libssl-dev \
    libtelnet-dev libtool libvncserver-dev libwebsockets-dev libwebp-dev make \
    libavcodec-dev libswscale-dev libvorbis-dev curl \
    ca-certificates ghostscript libfreerdp-plugins-standard \
    fonts-liberation fonts-dejavu xfonts-terminus default-jre \
    libossp-uuid16 libpangocairo-1.0-0 libpango-1.0-0 libwebsockets8 \
    libavcodec57 libswscale4 libvorbisenc2 libvorbisfile3 libssh2-1 libtelnet2 \
    libvncclient1 libfreerdp-client1.1 libfreerdp-cache1.1 && \
    cd /usr/local/src && \
    git clone https://github.com/apache/guacamole-server.git && \
    cd guacamole-server && autoreconf -fi && ./configure && \
    make -j$(getconf _NPROCESSORS_ONLN) && make install && ldconfig && \
    # Download Tomcat
    TOMCAT_VERSION=9.0.27 && \
    CATALINA_HOME=/usr/local/tomcat && \
    curl -sSL https://apache.mirrors.nublue.co.uk/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar -xzv -C /usr/local && \
    mv /usr/local/apache-tomcat-${TOMCAT_VERSION} /usr/local/tomcat && \
    chmod -R ugo=rwX ${CATALINA_HOME} && \
    # Download and install guacamole-client war
    GUACAMOLE_VERSION=1.0.0 && \
    curl -sSL "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war" -o ${CATALINA_HOME}/webapps/ROOT.war && \
    rm -rf ${CATALINA_HOME}/webapps/ROOT && \
    # Create simple launch script to start guacd and Tomcat
    echo '#!/bin/bash\n/usr/local/sbin/guacd -f &\nexec /usr/local/tomcat/bin/catalina.sh run' > /usr/local/bin/startup && \
    chmod +x /usr/local/bin/startup && \
    # Tidy up
    rm -rf /usr/local/src/guacamole-server && \
    apt-get clean && \
    apt-get purge -y \
    git autoconf automake gcc libcairo2-dev libfreerdp-dev libjpeg62-turbo-dev \
    libossp-uuid-dev libpango1.0-dev libpulse-dev libssh2-1-dev libssl-dev \
    libtelnet-dev libtool libvncserver-dev libwebsockets-dev libwebp-dev make \
    libavcodec-dev libswscale-dev libvorbis-dev curl && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/bin/startup"]

#-------------------------------------------------------------------------------
#
# To build the image
# docker build -t guacamole .
#

