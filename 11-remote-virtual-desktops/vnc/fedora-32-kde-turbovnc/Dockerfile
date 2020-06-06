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

FROM fedora-kde-vgl:32

RUN dnf -y install \
    chkconfig xorg-x11-fonts-base xorg-x11-fonts-75dpi \
    xorg-x11-fonts-100dpi numpy python-setuptools && \
    # Attempt to work out the latest turbovnc version from
    # https://sourceforge.net/projects/turbovnc/files/
    TVNC_VERSION=$(curl -sSL https://sourceforge.net/projects/turbovnc/files/ | grep "<span class=\"name\">[0-9]" | head -n 1 | cut -d \> -f2 | cut -d \< -f1) && \
    echo "turbovnc version: ${TVNC_VERSION}" && \
    curl -sSL https://sourceforge.net/projects/turbovnc/files/${TVNC_VERSION}/turbovnc-${TVNC_VERSION}.x86_64.rpm -o turbovnc-${TVNC_VERSION}.x86_64.rpm && \
    rpm -i turbovnc-*.x86_64.rpm && \
    rm turbovnc-*.x86_64.rpm && \
    ln -snf /opt/TurboVNC/bin/Xvnc /usr/bin/Xvnc && \
    # Download websockify
    WS_VERSION=0.9.0 && \
    curl -sSL https://github.com/novnc/websockify/archive/v${WS_VERSION}.tar.gz | tar -xzv -C /usr/local/bin && \
    cd /usr/local/bin/websockify-${WS_VERSION} && \
    python setup.py install && \
    # Download noVNC
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
    npm install -g @babel/core @babel/cli && \
    npm install -g @babel/preset-env && \
    ln -s ${NODE}/babel /usr/local/bin/babel && \
    ln -s ${NODE}/compile-modules \
          /usr/local/bin/compile-modules && \
    cd ${NOVNC} && \
    # Tweak the vnc.html to use the transpiled app.js
    # instead of modules.
    sed -i 's/type="module" crossorigin="anonymous" src="app\/ui.js"/src="app.js"/g' vnc.html && \
    sed -i 's/<script src="vendor\/promise.js"><\/script>//g' vnc.html && \
    sed -i 's/if (window._noVNC_has_module_support) //g' vnc.html && \
    # Transpile the Javascript to speed up loading and
    # allow it to work on a wider variety of browsers.
    echo '{"presets": ["@babel/preset-env"]}' > .babelrc && \
    npm install --save-dev @babel/core @babel/preset-env && \
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
    mv ${NOVNC}/vnc.html \
       /usr/local/bin/noVNC/index.html && \
    # Tidy up
    rm -rf ${NOVNC} && \
    rm -rf /usr/local/lib/node-v10.16.3-linux-x64 && \
    rm -rf /root/.npm && \
    rm /usr/local/bin/node && \
    rm /usr/local/bin/npm && \
    rm /usr/local/bin/npx && \
    # Create systemd service to launch noVNC
    echo -e '[Unit]\nDescription=HTML5 VNC WebSocket proxy\nAfter=syslog.target network.target\n\n[Service]\nUser=lightdm\nType=simple\nExecStart=/usr/local/bin/websockify 5800 localhost:5900 --web /usr/local/bin/noVNC\nTimeoutStopSec=20\nKillMode=process\nRestart=always\nRestartSec=2\n\n[Install]\nWantedBy=multi-user.target\nAlias=websocket.service\n' > /lib/systemd/system/websocket.service && \
    ln -snf /lib/systemd/system/websocket.service \
       /etc/systemd/system/multi-user.target.wants/websocket.service && \
    # Create Turbovnc-lightdm-wrapper
    echo -e '#!/bin/bash\nRFBPORT=$((5900+${1#:}))\nXvnc $1 -ac -nolisten tcp -localhost -rfbport $RFBPORT -rfbauth /tmp/lightdm/.vnc/passwd&\nXVNC_PID=$!\ncleanup() {\n  kill -TERM $XVNC_PID\n}\ntrap cleanup SIGINT SIGTERM EXIT\nsleep 0.25\nkill -USR1 $PPID\nsocat - TCP:localhost:$RFBPORT' > /usr/bin/Turbovnc-lightdm-wrapper && \
    chmod +x /usr/bin/Turbovnc-lightdm-wrapper && \
    echo -e '[LightDM]\nminimum-display-number=1\n[Seat:*]\nxserver-command=/usr/bin/Xephyr-lightdm-wrapper\n[VNCServer]\nenabled=true\ndepth=24\ncommand=Turbovnc-lightdm-wrapper' > /etc/lightdm/lightdm.conf.d/70-fedora.conf

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t fedora-kde-turbovnc:32 .

