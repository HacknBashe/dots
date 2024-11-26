#!/bin/bash

current_date=$(date "+%d %b %a %p %M %I")
date_parts=($current_date)

sketchybar --set clock.day label="${date_parts[0]}"

sketchybar --set clock.month label="${date_parts[1]}"

sketchybar --set clock.weekday label="${date_parts[2]}"

sketchybar --set clock.ampm label="${date_parts[3]}"

sketchybar --set clock.minutes label="${date_parts[4]}"

sketchybar --set clock.hours label="${date_parts[5]}" \
