#!/bin/bash

# This script is meant to be a central place to collect
# launching and focusing scripts
# What to make it do:
# - launch program if not open
# - focus program if open
# - cycle through focus if multiple for some programs

case $1 in
    chat)
        if [[ $(xdotool getwindowfocus getwindowname) = "Messenger" ]]; then
            (pgrep Discord && wmctrl -x -a discord) || discord &
        else
            (pgrep caprine && wmctrl -x -a caprine) || caprine &
        fi ;;
    
    music)
        pgrep mopidy || mopidy &
        if [[ $(xdotool getwindowfocus getwindowname) != "ncmpcpp" ]]; then
            (pgrep ncmpcpp && wmctrl -F -a ncmpcpp) || termite --role=ncmpcpp --title=ncmpcpp --icon=google-play-music-desktop-player --exec="ncmpcpp" &
        else
            (pgrep glava && killall glava) || glava --desktop > /dev/null 2>&1 &
        fi ;;
    
    browser)
        chromium & ;;
    code)
        pgrep code || code &
        if  pgrep code | grep $(xdotool getwindowfocus getwindowpid); then
            code &
        else
            wmctrl -x -a code-oss
        fi ;;
    droidcam)
        adb start-server; sleep 1
        adb forward tcp:4747 tcp:4747; sleep 1
        droidcam-cli 127.0.0.1 4747 ;;
        
esac