#!/bin/sh
# Outputs the pulse volume level formatted to be shown in polybar
name=$(pactl info | grep "Default Sink" | awk '{ print $3 }')

if [ "$name" == "alsa_output.pci-0000_07_00.6.analog-stereo" ]; then
  printf " "
else
  printf " "
fi