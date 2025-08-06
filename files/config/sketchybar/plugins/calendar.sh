#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Check if currently in a meeting
current_meetings=$(/opt/homebrew/bin/icalBuddy -n -nrd -nc -eed -tf "%H:%M" -ic "Family,nhackford@hubspot.com,Hubspot US Holidays" eventsNow)
in_meeting=false
current_meeting_title=""

if [[ -n "$current_meetings" ]]; then
    in_meeting=true
    current_meeting_title=$(echo "$current_meetings" | head -1 | sed 's/^• //')
fi

# Get the next upcoming event (skip current if in one)
delimiter="date:"
all_events=$(/opt/homebrew/bin/icalBuddy -n -nrd -nc -eed -df "date: %m-%d" -ic "Family,nhackford@hubspot.com,Hubspot US Holidays" eventsToday+10)

if [[ "$in_meeting" == true ]]; then
    # Skip the first event and get the next
    output=$(echo "$all_events" | awk '
        /^• / {eventName = $0}
        /date:/ && eventName {
            if (count++ > 0) {print eventName, $0; exit}
            eventName = ""
        }
    ')
else
    # Get the first event
    output=$(echo "$all_events" | awk '
        /^• / {eventName = $0}
        /date:/ && eventName {print eventName, $0; eventName = ""}
        ' | head -1)
fi

next_event=$(echo "$output" | sed "s/^• \(.*\)$delimiter.*$/\1/")
time=$(echo "$output" | sed "s/.*$delimiter //")

# Format time display
current_date=$(date "+%m-%d")
if [[ "$time" == *"$current_date"* ]]; then
    next_time="${time#*at }"
else
    next_time="$time"
fi

# Set the event label
sketchybar --set calendar.event label="$next_event"

# Set the time label  
sketchybar --set calendar.time label="$next_time"

# Set icon color based on meeting status
if [[ "$in_meeting" == true ]]; then
    # Check if current meeting contains "Focus Time"
    if [[ "$current_meeting_title" == *"Focus Time"* ]]; then
        sketchybar --set calendar.time icon.color=$SELECTED_COLOR
    else
        sketchybar --set calendar.time icon.color=$WARNING_COLOR
    fi
else
    sketchybar --set calendar.time icon.color=$FG_COLOR
fi
