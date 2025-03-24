#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
    selected=$(find -L ~/ ~/.config ~/src -maxdepth 3 \( -name node_modules -o -name Library \) -prune -o -type f -print | uniq | fzf)
fi

if [[ -z $selected ]]; then
  exit 0
fi

nvim "$selected"
