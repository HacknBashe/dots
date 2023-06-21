#!/bin/sh
tmux neww -c ~/codebase/sf-ui-web/apps/sf-ui-layout
tmux send-keys 'yarn dev'
tmux split-window -h -l 66% -c ~/codebase/sf-ui-web/apps/sf-ui-layout
tmux send-keys 'yarn rndr:watch'
tmux split-window -h -c ~/codebase/sf-ui-web/libs/header-experience
tmux send-keys 'yarn watch' C-m
tmux select-pane -L
tmux split-window -v -l 6 -b -c ~/codebase/sf-ui-web/apps/sf-ui-layout
tmux send-keys 'yarn rndr:tunnel' C-m
