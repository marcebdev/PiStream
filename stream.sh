#!/bin/bash

#  PiStream - a realtime video stream manager
#  Copyright (C) 2017 Marcello Barbieri

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

receive() {
  gst-launch-1.0 udpsrc port=$PORT ! application/x-rtp, payload=96 ! rtph264depay ! avdec_h264 ! autovideosink sync=false
}

transmit() {

  if [[ -z $IP ]] ; then
     printf '%s\n' "Error: No IP Selected"
     exit 1
  fi

  #enables v4l2 adapter for rpi cam
  sudo modprobe bcm2835-v4l2

  #gst-launch-1.0 -ve v4l2src ! 'video/x-raw, width=1280, height=720, framerate=30/1' \
  #! omxh264enc target-bitrate=${stream[bitrate]} control-rate=variable ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=$IP port=$PORT

video="'video/x-raw, width=${stream[width]}, height=${stream[height]}, framerate=${stream[framerate]}''"

  gst-launch-1.0 -ve v4l2src ! $video \
  ! omxh264enc target-bitrate=${stream[bitrate]} control-rate=variable ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=$IP port=$PORT
}

IP="$2"
[ -z $PORT ] && PORT=5000

case $1 in
  low|l)
    printf '%s\n' "480p Selected"
    declare -A stream=(["width"]="640" ["height"]="480" ["framerate"]="30/1" ["bitrate"]="500000" )
    transmit ;;
  med|m)
    printf '%s\n' "720p Selected"
    declare -A stream=(["width"]="1280" ["height"]="720" ["framerate"]="30/1" ["bitrate"]="4000000" )
    transmit ;;
  high|h)
    ;;
  receive|r)
    receive ;;
  *)
    printf '%s\n' "invalid option" ;;
esac
