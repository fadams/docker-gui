#!/bin/bash
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

################################################################################
# Iterate through every ALSA PCM device and attempt to play a simple wav
# With ALSA there are often *many* devices available and it can often be a
# bit of a mystery trying to work out which one is actually connected to
# the speakers because the enumeration can often be a bit cryptic.
################################################################################

for i in $(aplay -L | grep CARD); do
    echo trying device $i
    aplay -D $i $HOME/ok.wav
    echo
    sleep 1
done
