#!/bin/bash

#if [ "$(headsetcontrol -b | grep Failed)" == "Failed to request battery. Error: -93: (null)" ]; then
#    echo "failed"
#else
#    echo "$(headsetcontrol -b | grep "Battery" | awk '{ print $2 }')"
#fi

headsetcontrol -b 2>/dev/null 1>/dev/null
case $? in
    0) echo "$(headsetcontrol -b | grep "Battery" | awk '{ print $2 }')" ;;
    *) echo "Headset not connected" ;;
esac