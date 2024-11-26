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
    COMMAND_OUTPUT=$(hyprctl monitors)
    SEARCH_STRING="LG TV"

    if grep -q "$SEARCH_STRING" <<<"$COMMAND_OUTPUT"; then
        echo "󰟴"
    else
        echo "󰠺"
    fi
done

exit 0
