#!/usr/bin/env bash
# Color with ANSI palette
%hidden thm_bg="default"
%hidden thm_black="colour0"
%hidden thm_yellow="colour11"
%hidden thm_blue="colour12"
%hidden thm_pink="colour13"
%hidden thm_white="colour15"
%hidden thm_grey="colour16"
%hidden thm_orange="colour17"

%hidden LEFT=
%hidden RIGHT=

set -g mode-style "fg=$thm_black,bg=$thm_white"
set -g message-style "fg=$thm_yellow,bg=$thm_bg"
set -g message-command-style "fg=$thm_pink,bg=$thm_bg"
set -g pane-border-indicators "colour"
set -g pane-border-style "fg=$thm_black"
set -g pane-active-border-style "fg=$thm_blue"
set -g status "on"
set -g status-justify "left"
set -g status-style "fg=$thm_white,bg=$thm_bg"
set -g status-left-length "100"
set -g status-right-length "100"
set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[bg=$thm_bg,bold]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_blue]} #[fg=$thm_blue]#S $LEFT"
set -g status-right "#[bg=$thm_bg,fg=$thm_blue]%y-%m-%d $RIGHT %H:%M:%S "
setw -g window-status-activity-style "underscore,fg=$thm_grey,bg=$thm_black"
setw -g window-status-separator ""
setw -g window-status-format "#[fg=$thm_grey,bg=$thm_bg] #I $LEFT #{b:pane_current_path} #F #W $LEFT"
setw -g window-status-current-format "#[fg=$thm_white,bg=$thm_bg,bold] #I $LEFT #[underscore]./#{b:pane_current_path}#[nounderscore] #F #[underscore]#W#[fg=$thm_white,bg=$thm_bg,nobold,nounderscore,noitalics] $LEFT"
