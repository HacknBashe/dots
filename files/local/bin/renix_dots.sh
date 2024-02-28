#!/usr/bin/env bash

dots_dir="$HOME/.config/dots/files"
input_file="$HOME/.config/denixed-links.txt"

if [ -e "$input_file" ]; then
  while IFS= read -r config_path && [[ -n "$config_path" ]]; do
    trimmed_config_file="${config_path#$HOME}"
    trimmed_config_file=$(echo "${trimmed_config_file}" | sed 's|/\.*|/|g')
    dot_path="${dots_dir}${trimmed_config_file}"

    read -r store_path

    if [ -e "$dot_path" ]; then
      rm $dot_path
      mv $config_path $dot_path
      ln -s "$store_path" "$config_path"
    fi
  done <$input_file
  rm "$input_file"

  echo renixed dot files
else
  echo no denixed-links.txt
fi
