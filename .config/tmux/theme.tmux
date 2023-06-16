#!/usr/bin/env bash
# Heavily modified nordfox
# Upstream: https://github.com/edeneast/nightfox.nvim/raw/main/extra/nordfox/nightfox_tmux.tmux

%hidden thm_fg="#7e8188"
%hidden thm_bg="default"
%hidden thm_grey="#abb1bb"
%hidden thm_black="#232831"
%hidden thm_red="#bf616a"
%hidden thm_orange="#c9826b"
%hidden thm_yellow="#ebcb8b"
%hidden thm_green="#a3be8c"
%hidden thm_blue="#81a1c1"
%hidden thm_cyan="#88c0d0"
%hidden thm_magenta="#b48ead"
%hidden thm_pink="#bf88bc"

%hidden LEFT1=
%hidden LEFT2=
%hidden LEFT3=
%hidden RIGHT1=
%hidden RIGHT2=
%hidden RIGHT3=

# Set the foreground/background color for the active window
setw -g window-style bg=default
setw -g window-active-style bg=default

set -g mode-style "fg=$thm_black,bg=$thm_grey"
set -g message-style "fg=$thm_yellow,bg=$thm_bg"
set -g message-command-style "fg=$thm_pink,bg=$thm_bg"
set -g pane-border-style "fg=$thm_grey"
set -g pane-active-border-style "fg=$thm_blue"
set -g status "on"
set -g status-justify "left"
set -g status-style "fg=$thm_grey,bg=$thm_bg"
set -g status-left-length "100"
set -g status-right-length "100"
set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#{pane_input_off}#[fg=$thm_blue,bg=$thm_bg,bold] #S $LEFT2"
set -g status-right "#[bg=$thm_bg]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_blue]}%y-%m-%d $RIGHT2 %H:%M:%S "
setw -g window-status-activity-style "underscore,fg=$thm_fg,bg=$thm_black"
setw -g window-status-separator ""
setw -g window-status-format "#[fg=$thm_fg,bg=$thm_bg] #I $LEFT2 #{b:pane_current_path} #F #W $LEFT2"
setw -g window-status-current-format "#[fg=$thm_grey,bg=$thm_bg,bold] #I $LEFT2 #[underscore]./#{b:pane_current_path}#[nounderscore] #F #[underscore]#W#[fg=$thm_grey,bg=$thm_bg,nobold,nounderscore,noitalics] $LEFT2"
