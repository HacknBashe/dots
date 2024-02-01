#!/usr/bin/env bash

dots_path="$HOME/.config/nix-config/dots"
output_file="$HOME/.config/denixed-links.txt"

if [ -e "$output_file" ]; then
  echo denixed-links.txt already exists
else
  touch "$output_file"

  find "$dots_path" -type f | while read dot_file; do
    config_file="$HOME${dot_file#$HOME/.config/nix-config/dots}"
    store_file=$(readlink "$config_file")

    if [ "$store_file" ]; then
      echo "$config_file" >>"$output_file"
      echo "$store_file" >>"$output_file"
      rm "$config_file"
      cp "$store_file" "$config_file"
      chmod +w "$config_file"
    fi
  done
fi

echo denixed dot files
