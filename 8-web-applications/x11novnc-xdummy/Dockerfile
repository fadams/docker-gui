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

FROM x11vnc-xdummy

# Install noVNC
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl xz-utils ca-certificates && \
    # Download noVNC.
    NOVNC_VERSION=1.1.0 && \
    NOVNC=/usr/local/bin/noVNC-${NOVNC_VERSION} && \
    APP=/usr/local/bin/noVNC/app && \
    curl -sSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    # Temporarily install Node.js and npm to transpile
    # ECMAScript 6 modules. As well as speeding up load times
    # on browsers that don't support modules this circumvents
    # an issue with pre 0.9.12 LibVNCServer where the MIME
    # type for Javascript was set incorrectly causing Chrome
    # to reject them due to strict MIME type checking being
    # enabled for modules.
    curl -sSL https://nodejs.org/dist/v10.16.3/node-v10.16.3-linux-x64.tar.xz | tar -xJv -C /usr/local/lib && \
    NODE=/usr/local/lib/node-v10.16.3-linux-x64/bin && \
    ln -s ${NODE}/node /usr/local/bin/node && \
    ln -s ${NODE}/npm /usr/local/bin/npm && \
    ln -s ${NODE}/npx /usr/local/bin/npx && \
    npm install -g es6-module-transpiler && \
    npm install -g @babel/cli && \
    npm install --save-dev @babel/core @babel/preset-env && \
    ln -s ${NODE}/babel /usr/local/bin/babel && \
    ln -s ${NODE}/compile-modules \
          /usr/local/bin/compile-modules && \
    cd ${NOVNC} && \
    # Tweak noVNC configuration as the defaults point to 
    # websockify not the built-in x11vnc websocket support.
    sed -i "s/UI.initSetting('port', port)/UI.initSetting('port', 5900)/g" app/ui.js && \
    sed -i "s/UI.initSetting('path', 'websockify')/UI.initSetting('path', '')/g" app/ui.js && \
    # Tweak the vnc.html to use the transpiled app.js
    # instead of modules.
    sed -i 's/type="module" crossorigin="anonymous" src="app\/ui.js"/src="app.js"/g' vnc.html && \
    sed -i 's/<script src="vendor\/promise.js"><\/script>//g' vnc.html && \
    sed -i 's/if (window._noVNC_has_module_support) //g' vnc.html && \
    # Transpile the Javascript to speed up loading and
    # allow it to work on a wider variety of browsers.
    echo '{"presets": ["@babel/preset-env"]}' > .babelrc && \
    compile-modules convert app/ui.js > app.js && \
    babel app.js --out-file app.js && \
    mkdir -p ${APP} && \
    mv ${NOVNC}/app/images ${APP}/images && \
    mv ${NOVNC}/app/locale ${APP}/locale && \
    mv ${NOVNC}/app/sounds ${APP}/sounds && \
    mv ${NOVNC}/app/styles ${APP}/styles && \
    mv ${NOVNC}/app/error-handler.js \
       ${APP}/error-handler.js && \
    mv ${NOVNC}/app.js ${APP}.js && \
    # Renaming vnc.html to index.vnc seems necessary as the
    # x11vnc built-in web server seems to serve index.vnc
    # by default and there's no obvious configuration
    # option to change this.
    mv ${NOVNC}/vnc.html \
       /usr/local/bin/noVNC/index.vnc && \
    # Create script to start Xorg, jwm and x11vnc
    echo '#!/bin/bash\nXorg $DISPLAY -cc 4 &\nsleep 0.5\njwm &\nx11vnc -forever -usepw -httpdir /usr/local/bin/noVNC' > /usr/local/bin/startup && \
    chmod +x /usr/local/bin/startup && \
    # Tidy up
    rm -rf ${NOVNC} && \
    rm -rf /usr/local/lib/node-v10.16.3-linux-x64 && \
    rm -rf /root/.npm && \
    rm /usr/local/bin/node && \
    rm /usr/local/bin/npm && \
    rm /usr/local/bin/npx && \
    apt-get clean && \
    apt-get purge -y curl xz-utils && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/bin/startup"]

#-------------------------------------------------------------------------------
# 
# To build the image
# docker build -t x11novnc-xdummy .
#

