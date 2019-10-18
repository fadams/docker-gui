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

ENV LANG=en_GB.UTF-8
ENV TZ=Europe/London

# Install x11vnc and xserver-xorg-video-dummy
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl xz-utils ca-certificates libgl1-mesa-glx libgl1-mesa-dri \
    x11vnc xserver-xorg-video-dummy locales jwm && \
    # Download noVNC.
    NOVNC_VERSION=1.1.0 && \
    curl -sSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    # Temporarily install Node.js and npm to transpile ECMAScript 6 modules.
    # As well as speeding up load times on browsers that don't support modules
    # this circumvents an issue with pre 0.9.12 LibVNCServer where the
    # MIME type for Javascript was set incorrectly causing Chrome to reject
    # them due to strict MIME type checking being enabled for modules.
    curl -sSL https://nodejs.org/dist/v10.16.3/node-v10.16.3-linux-x64.tar.xz | tar -xJv -C /usr/local/lib && \
    ln -s /usr/local/lib/node-v10.16.3-linux-x64/bin/node /usr/local/bin/node && \
    ln -s /usr/local/lib/node-v10.16.3-linux-x64/bin/npm /usr/local/bin/npm && \
    ln -s /usr/local/lib/node-v10.16.3-linux-x64/bin/npx /usr/local/bin/npx && \
    npm install -g es6-module-transpiler && \
    npm install -g @babel/cli && \
    npm install --save-dev @babel/core @babel/preset-env && \
    ln -s /usr/local/lib/node-v10.16.3-linux-x64/bin/babel /usr/local/bin/babel && \
    ln -s /usr/local/lib/node-v10.16.3-linux-x64/bin/compile-modules /usr/local/bin/compile-modules && \
    cd /usr/local/bin/noVNC-${NOVNC_VERSION} && \
    echo '{"presets": ["@babel/preset-env"]}' > .babelrc && \
    # Tweak noVNC configuration as the defaults point to websockify not the
    # built-in x11vnc websocket support.
    sed -i "s/UI.initSetting('port', port)/UI.initSetting('port', 5900)/g" app/ui.js && \
    sed -i "s/UI.initSetting('path', 'websockify')/UI.initSetting('path', '')/g" app/ui.js && \
    # Tweak the vnc.html to use the transpiled app.js instead of modules.
    sed -i 's/type="module" crossorigin="anonymous" src="app\/ui.js"/src="app.js"/g' vnc.html && \
    sed -i 's/<script src="vendor\/promise.js"><\/script>//g' vnc.html && \
    sed -i 's/if (window._noVNC_has_module_support) //g' vnc.html && \
    # Transpile the Javascript to speed up loading and allow it to work on
    # a wider variety of browsers.
    compile-modules convert app/ui.js > app.js && \
    babel app.js --out-file app.js && \
    mkdir -p /usr/local/bin/noVNC/app && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app/images /usr/local/bin/noVNC/app/images && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app/locale /usr/local/bin/noVNC/app/locale && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app/sounds /usr/local/bin/noVNC/app/sounds && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app/styles /usr/local/bin/noVNC/app/styles && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app/error-handler.js /usr/local/bin/noVNC/app/error-handler.js && \
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/app.js /usr/local/bin/noVNC/app.js && \
    # Renaming vnc.html to index.vnc seems necessary as the x11vnc built-in
    # web server seems to serve index.vnc by default and there's no obvious
    # configuration option to change this.
    mv /usr/local/bin/noVNC-${NOVNC_VERSION}/vnc.html /usr/local/bin/noVNC/index.vnc && \
    #
    # Create simple launch script to start Xorg, jwm and x11vnc
    echo '#!/bin/bash\nXorg $DISPLAY -cc 4 &\nsleep 0.5\njwm &\nx11vnc -forever -usepw -httpdir /usr/local/bin/noVNC' > /usr/local/bin/startup && \
    chmod +x /usr/local/bin/startup && \
    # Generate locales
    sed -i "s/^# *\($LANG\)/\1/" /etc/locale.gen && locale-gen && \
    # Set up the timezone
    echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata && \
    # Tidy up JWM for single app use case
    sed -i "s/Desktops width=\"4\"/Desktops width=\"1\"/g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton icon=\"\/usr\/share\/jwm\/jwm-red.svg\">root:1<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<TrayButton label=\"_\">showdesktop<\/TrayButton>//g" /etc/jwm/system.jwmrc && \
    sed -i "s/<Include>\/etc\/jwm\/debian-menu<\/Include>//g" /etc/jwm/system.jwmrc && \
    # We'll be exporting /tmp/.X11-unix as a volume and we need
    # the mode of /tmp/.X11-unix to be set to 1777
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    # Tidy up
	rm -rf /usr/local/bin/noVNC-${NOVNC_VERSION} && \
	rm -rf /usr/local/lib/node-v10.16.3-linux-x64 && \
	rm -rf /root/.npm && \
	rm /usr/local/bin/node && \
	rm /usr/local/bin/npm && \
	rm /usr/local/bin/npx && \
    apt-get clean && \
    apt-get purge -y curl xz-utils && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

VOLUME /tmp/.X11-unix

COPY xorg.conf /etc/X11/xorg.conf

CMD ["/usr/local/bin/startup"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t x11novnc-xdummy .
#

