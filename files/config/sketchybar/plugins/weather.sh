#!/bin/bash

WEATHER_CODES=(
  [113]=""
  [116]=""
  [119]=""
  [122]=""
  [143]=""
  [176]=""
  [179]=""
  [182]=""
  [185]=""
  [200]=""
  [227]=""
  [230]=""
  [248]=""
  [260]=""
  [263]=""
  [266]=""
  [281]=""
  [284]=""
  [293]=""
  [296]=""
  [299]=""
  [302]=""
  [305]=""
  [308]=""
  [311]=""
  [314]=""
  [317]=""
  [320]=""
  [323]=""
  [326]=""
  [329]=""
  [332]=""
  [335]=""
  [338]=""
  [350]=""
  [353]=""
  [356]=""
  [359]=""
  [362]=""
  [365]=""
  [368]=""
  [371]=""
  [374]=""
  [377]=""
  [386]=""
  [389]=""
  [392]=""
  [395]=""
)

format_time() {
  echo "$1" | sed 's/00//' | xargs printf "%2s"
}

format_temp() {
  printf "%s°%-3s" "$1"
}

format_chances() {
  local data=$1
  local conditions=""

  # Check various chance conditions
  for event in "fog" "frost" "overcast" "rain" "snow" "sunshine" "thunder" "wind"; do
    value=$(echo "$data" | jq -r ".chanceof${event}")
    if [ "$value" != "0" ] && [ "$value" != "null" ]; then
      [ -n "$conditions" ] && conditions="$conditions, "
      conditions="$conditions${event^} ${value}%"
    fi
  done
  echo "$conditions"
}

weather_data=$(curl -s "wttr.in/Lancaster,+New+York?format=j1")

if [ $? -ne 0 ]; then
  echo "󰼯"
  echo "Wttr.in fetch error."
  return 1
fi

# Current conditions
weather_code=$(echo "$weather_data" | jq -r '.current_condition[0].weatherCode')
feels_like=$(echo "$weather_data" | jq -r '.current_condition[0].FeelsLikeF')
weather_icon="${WEATHER_CODES[$weather_code]}"

# Simple output (similar to the widget's label)

# Detailed output (similar to the tooltip)
# {
#   # Current conditions header
#   echo -e "\033[1m$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value') $(echo "$weather_data" | jq -r '.current_condition[0].temp_C')°\033[0m"
#   echo "Feels like: ${feels_like}°"
#   echo "Wind: $(echo "$weather_data" | jq -r '.current_condition[0].windspeedKmph')Km/h"
#   echo "Humidity: $(echo "$weather_data" | jq -r '.current_condition[0].humidity')%"
#   echo ""
#
#   # Forecast for today and tomorrow
#   echo "$weather_data" | jq -r '.weather[] | select(.date != null) | . as $day |
#       if .date == (now | strftime("%Y-%m-%d")) then "Today, "
#       elif .date == ((now + 86400) | strftime("%Y-%m-%d")) then "Tomorrow, "
#       else "" end +
#       .date + "\n" +
#       .maxtempC + "°  " + .mintempC + "°   " +
#       .astronomy[0].sunrise + "  " + .astronomy[0].sunset + "\n" +
#       (.hourly[] |
#         if (($day.date == (now | strftime("%Y-%m-%d"))) and
#             (((.time | tonumber) / 100) < ((now | strftime("%H")) | tonumber - 2)))
#         then empty
#         else
#           ((.time | tonumber / 100) | floor | tostring | if length == 1 then " " + . else . end) +
#           " " + "\(.weatherCode)" + " " +
#           (.FeelsLikeF + "°") + " " +
#           .weatherDesc[0].value + ", " +
#           (if .chanceofrain != "0" then "Rain " + .chanceofrain + "% " else "" end) +
#           (if .chanceofsnow != "0" then "Snow " + .chanceofsnow + "% " else "" end) +
#           "\n"
#         end)'
# } | fold -s -w 80

sketchybar \
  --set weather.temp label="$feels_like°"

sketchybar \
  --set weather.icon icon=$weather_icon
