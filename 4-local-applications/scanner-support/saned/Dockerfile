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

# Install sane-utils
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    # Add the packages used
    apt-get install -y --no-install-recommends \
	sane-utils && \
	rm -rf /var/lib/apt/lists/* && \
    # Set up /etc/sane.d/saned.conf in container
    # Tell saned to use 10000 and 10001 as data ports.
    sed -i "s/# data_portrange = 10000 - 10100/data_portrange = 10000 - 10001/g" /etc/sane.d/saned.conf && \
    # Tell saned to share with everyone on the local network 192.168.0.0 and
    # everyone on the Docker bridge network 172.17.0.0. 
    sed -i "s/scan-client.somedomain.firm/scan-client.somedomain.firm\n192.168.0.0\/24\n172.17.0.0\/24/g" /etc/sane.d/saned.conf && \
    # Add saned user to lp group
    usermod -a -G lp saned && \
    # Add script to run saned with debug output
    echo "while true; do scanimage -f %d; echo; saned -d5; done" > /usr/src/saned.sh && \
    chmod +x /usr/src/saned.sh

# Run saned as the non privileged user saned.
USER saned

CMD /usr/src/saned.sh

#-------------------------------------------------------------------------------
# Example usage
# 
# Build the image
# docker build -t saned .

