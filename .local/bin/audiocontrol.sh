#!/bin/bash
# Attempt at putting all my audio stuff into one script
# Should be able to:
#   - Launch/focus music player - done
#   - Control mpd - done
#   - Control volume - done
#   - Switch headphone and speaker profiles - done

usage() {
    echo "Usage: audiocontrol.sh [OPTION] [ARG]
-v      Volume control. Args: [mute], [increase [int]], [decrease [int]]
-l      Launches mopidy and ncmpcpp or toggles glava if both open
-s      Switches between headphones and speaker output
-p      Playerctl with some specific options. Args: [next],[previous],[playpause]"
}


main() {
    while getopts ":v:lsp:" opt; do
        case "$opt" in
        v) instr="volume";;
        l) instr="launcher";;
        s) instr="switchoutput";;
        p) instr="player";;
        :) instr="usage";;
        *) echo "invalid options"; instr="usage";;
        esac
    done
    shift
    $instr "$@"
}

# ============ Main Functions ================

volume() {

    # Set msgId for dunst to make repeat notifications not make a list
    msgId="991049"

    # Mute/change volume
    case $1 in
        mute) amixer set Master toggle;;
        decrease) pamixer -d $2;;
        increase) pamixer -i $2;;
        *) usage && exit 1;;
    esac

    # Handle the notification
    vol="$(pamixer --get-volume)"
    msgId="991049" # Arbitrary id so multiple notifications will stack
    if [[ "$(pamixer --get-volume-human)" == "muted" ]]; then
        icon="notification-audio-volume-muted"
    elif [ $vol -lt 30 ]; then
        icon="notification-audio-volume-low"
    elif [ $vol -lt 50 ]; then
        icon="notification-audio-volume-medium"
    else
        icon="notification-audio-volume-high"
    fi
    dunstify -u low -i "$icon" -r "$msgId" "$vol%"
}

launcher() {

    # Launch things if they aren't open and toggle glava
    pgrep mopidy || mopidy &
    if [[ $(pgrep ncmpcpp) ]]; then
        if [[ $(xdotool getwindowfocus getwindowname) = "ncmpcpp" ]]; then
            if [[ $(pgrep glava) ]]; then
                killall glava
            else
                glava --desktop &
            fi
        else
            wmctrl -F -a ncmpcpp
        fi
    else
        termite --role=ncmpcpp --title=ncmpcpp --icon=google-play-music-desktop-player --exec="ncmpcpp" &
    fi
}

player() {

    # Controls next/prev/play button functions
    # Easily mapped in openbox rc.xml but I put this here
    #   for future expandability

    case $1 in
        next) playerctl --player=mopidy,google_play_music_desktop_player,%any next ;;
        previous) playerctl --player=mopidy,google_play_music_desktop_player,%any previous ;;
        playpause) playerctl --player=mopidy,%any play-pause ;;
    esac
}

switchoutput() {

    headphones="alsa_output.usb-Logitech_Logitech_G930_Headset-00.analog-stereo"
    speakers="alsa_output.pci-0000_07_00.6.analog-stereo"
    msgId="991042"

    # Gather all current audio streams into one list
    streams=()
    while read -r stream; do
        streams+=($stream)
    done < <(pactl list short sink-inputs | awk '{ print $1 }')

    # Find default sink
    defaultName=$(pactl info | grep "Default Sink" | awk '{ print $3 }')

    if [[ "$defaultName" = "$speakers" ]]; then
        pactl set-default-sink $headphones
        newSink=$headphones
        dunstify -u low -i "audio-headphones" -r "$msgId" "Headphones" 
    else
        pactl set-default-sink $speakers
        newSink=$speakers
        dunstify -u low -i "audio-speakers" -r "$msgId" "Speaker"
    fi

    # cycle through streams and switch them to default
    for s in "${streams[@]}"; do
        pactl move-sink-input $s $newSink
    done

    polybar-msg hook audiosink 1
}

main "$@"