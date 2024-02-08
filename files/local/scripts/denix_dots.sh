#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory_or_symlink>"
  exit 1
fi

path="$1"

output_file="$HOME/.config/denixed-links.txt"

touch "$output_file"

if [ -d "$path" ]; then
  for link_path in "$path"/*; do
    if [ -L "$link_path" ]; then
      config_path=$(realpath -s "$link_path")
      store_path=$(readlink -f "$link_path")

      if [ "$store_path" ]; then
        echo "$config_path" >>"$output_file"
        echo "$store_path" >>"$output_file"
        rm "$config_path"
        cp "$store_path" "$config_path"
        chmod +w "$config_path"
      fi
    fi
  done
else
  if [ -L "$path" ]; then
    config_path=$(realpath -s "$path")
    store_path=$(readlink -f "$path")

    if [ "$store_path" ]; then
      echo "$config_path" >>"$output_file"
      echo "$store_path" >>"$output_file"
      rm "$config_path"
      cp "$store_path" "$config_path"
      chmod +w "$config_path"
    fi
  else
    echo "Error: '$path' is not a directory or a symlink."
    exit 1
  fi
fi

echo "denixed '$path'"
