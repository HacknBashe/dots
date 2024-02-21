#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find -L ~/ ~/codebase ~/.config -maxdepth 3 -type f | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

vim "$selected"
