#!/bin/bash

delimiter="date:"

# output=$(icalBuddy -n -nrd -nc -eed -df "date: %m-%d" -ic "nhackford@hubspot.com,Hubspot US Holidays" eventsToday+10 | awk '
output=$(icalBuddy -n -nrd -nc -eed -df "date: %m-%d" -ic "nhackford@hubspot.com,Hubspot US Holidays" eventsToday+10 | awk '
    /^• / {eventName = $0}
    /\date:/ && eventName {print eventName, $0; eventName = ""}
    ' | head -n 1)
event=$(echo $output | sed "s/^• \(.*\)$delimiter.*$/\1/")
time=$(echo $output | sed "s/.*$delimiter//")

currentdate=$(date "+%m-%d")

sketchybar --set calendar.event label="$event"

if [[ "$time" == *"$currentdate"* ]]; then
  time="${time#*at }"
elif [[ "$time" == *"at "* ]]; then
  time="${time#*$currentdate}"
fi
sketchybar --set calendar.time label="$(echo $time)"
