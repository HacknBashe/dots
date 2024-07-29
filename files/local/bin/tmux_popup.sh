#!/usr/bin/env bash

width=${2:-80%}
height=${2:-80%}
if [[ "$(tmux display-message -p -F "#{session_name}")" == *"_popup" ]]; then
    tmux detach-client
else
    tmux popup -d '#{pane_current_path}' -xC -yC -w$width -h$height -E "tmux attach -t $(tmux display-message -p -F "#{session_name}")_popup || tmux new -s $(tmux display-message -p -F "#{session_name}")_popup"
fi
