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

# PulseAudio and HDMI often don't play nicely together, especially
# where multiple cards and devices are involved. One issue is that
# it is possible for the default/selected sink to *not* be the
# first enumerated HDMI sink, if this happens audio won't be played
# by the client because NoMachine only seems to list the first
# enumerated sink.
#
# This script attempts to work around this by unloading the module(s)
# that relate to the non-default HDMI sink. so that the one we want
# becomes the first to be enumerated.

# Is there a neater way to retrieve the default sink?
DEFAULT_SINK=$(pactl info | sed -n -e 's/Default Sink: //p')

#echo $DEFAULT_SINK

if [[ $DEFAULT_SINK == *"hdmi"* ]]; then
  # Iterate through all the HDMI sinks until we reach the default
  # and store them in an array, which represents all HDMI sinks
  # enumerated before our default/selected one.
  arr=()
  IFS=$'\n'; for i in $(pactl list short sinks | grep hdmi); do
    if [[ $i == *"$DEFAULT_SINK"* ]]; then
      break
    else
      arr+=($i)
    fi
  done

  # For each HDMI sink enumerated before our default, find the
  # associated module and unload it then reload using the same
  # properties. This should ensure that the default/selected HDMI
  # sink gets enumerated first.
  for i in ${arr[@]}; do
    ALSA_CARD=$(echo $i | cut -d. -f2,3)
    for j in $(pactl list short modules | grep module-alsa-card); do
      if [[ $j == *"$ALSA_CARD"* ]]; then
        MODULE_INDEX=$(echo $j | cut -f1)
        MODULE_PROPERTIES="pactl load-module $(echo $j | cut -f2- | sed -n -e 's/\t/ /p')"
#echo $j
#echo $MODULE_INDEX
#echo $MODULE_PROPERTIES
#echo $ALSA_CARD
        pactl unload-module $MODULE_INDEX
        eval $MODULE_PROPERTIES
      fi
    done
  done
else
  echo "$DEFAULT_SINK is not HDMI, exiting!"
fi

