#!/usr/bin/env bash

dots_dir="$HOME/.config/nix-config/dots"
input_file="$HOME/.config/denixed-links.txt"

if [ -e "$input_file" ]; then
  while IFS= read -r config_file && [[ -n "$config_file" ]]; do
    trimmed_config_file="${config_file#$HOME}"
    dots_file="${dots_dir}${trimmed_config_file}"

    read -r store_file

    if [ -e "$dots_file" ]; then
      rm $dots_file
      mv $config_file $dots_file
      ln -s "$store_file" "$config_file"
    fi
  done <$input_file
  rm "$input_file"

  echo renixed dot files
else
  echo no denixed-links.txt
fi
