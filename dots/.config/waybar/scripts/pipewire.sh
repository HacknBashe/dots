#!/usr/bin/env bash

set -e

# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever
snore() {
    local IFS
    [[ -n "${_snore_fd:-}" ]] || exec {_snore_fd}<> <(:)
    read -r ${1:+-t "$1"} -u $_snore_fd || :
}

DELAY=0.2

while snore $DELAY; do
    COMMAND_OUTPUT=$(wpctl status)
    SEARCH_STRING="Audio/Sink    alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.playback.0.0"

    WP_OUTPUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    if [[ $WP_OUTPUT =~ ^Volume:[[:blank:]]([0-9]+)\.([0-9]{2})([[:blank:]].MUTED.)?$ ]]; then
        if [[ -n ${BASH_REMATCH[3]} ]]; then
            if grep -q "$SEARCH_STRING" <<< "$COMMAND_OUTPUT"; then
                echo "󰟎 $VOLUME"
            else
                echo "󰓄 $VOLUME"
            fi
        else
            VOLUME=$((10#${BASH_REMATCH[1]}${BASH_REMATCH[2]}))
            if grep -q "$SEARCH_STRING" <<< "$COMMAND_OUTPUT"; then
                echo "󰋋 $VOLUME"
            else
                echo "󰓃 $VOLUME"
            fi
        fi
    fi
done

exit 0
