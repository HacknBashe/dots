#!/usr/bin/env bash
cleanup() {
  tput rmcup
  exit
}

trap cleanup SIGINT

if [[ $# -eq 1 ]]; then
  selected=$1
fi

declare -A items=(
  ["^"]="$HOME/codebase"
  ["("]="$HOME/notes"
  [")"]="$HOME/.config/dots"
)
keys=("!" "@" "#" "$" "%" "^" "(" ")")

zoxide=$(zoxide query -l -s | awk '{print $NF}')

patterns=$(for key in "${!items[@]}"; do
  echo "${items[$key]}"
done)

filtered=$(echo "$zoxide" | grep -Ev "$(echo "${patterns[*]}")" | head -n 5)

index=0
while read -r path; do
  items[${keys[$index]}]="$path"
  ((index++))
done <<<"$filtered"

if [[ -z "$selected" ]]; then
  tput smcup

  lines=$(tput lines)
  bottom_row=$((lines - 1))
  echo -en "\e[${bottom_row};1H"

  echo "Select a project:"
  for key in "${keys[@]}"; do
    if [[ -n "${items[$key]}" ]]; then
      echo "$key - ${items[$key]}"
    fi
  done

  read -n1 -r selected

  tput rmcup
fi

if [[ -n "${items[$selected]}" ]]; then
  selected_item="${items[$selected]}"
  tmux_sessionizer.sh $selected_item
else
  if [ -n "$TMUX" ]; then
    read -p "Invalid key selected. Press any key to continue..."
  else
    echo "Invalid key selected."
  fi
fi
