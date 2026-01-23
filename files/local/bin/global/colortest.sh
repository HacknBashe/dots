#!/usr/bin/env bash

echo -e "\033[30m          Black 01 ██ Base00 ---- Dark"
echo -e "\033[92m   Bright Green 11 ██ Base01 ---"
echo -e "\033[93m         Bright 12 ██ Base02 --"
echo -e "\033[90m   Bright Black 09 ██ Base03 -"
echo -e "\033[94m    Bright Blue 13 ██ Base04 +"
echo -e "\033[37m          White 08 ██ Base05 ++"
echo -e "\033[95m Bright Magenta 14 ██ Base06 +++"
echo -e "\033[97m   Bright White 16 ██ Base07 ++++ Light"
echo -e "\033[31m            Red 02 ██ Base08 Red"
echo -e "\033[91m     Bright Red 10 ██ Base09 Orange"
echo -e "\033[33m         Yellow 04 ██ Base0A Yellow"
echo -e "\033[32m          Green 03 ██ Base0B Green"
echo -e "\033[36m           Cyan 07 ██ Base0C Cyan"
echo -e "\033[34m           Blue 05 ██ Base0D Blue"
echo -e "\033[35m        Magenta 06 ██ Base0E Purple"
echo -e "\033[96m    Bright Cyan 15 ██ Base0F Brown"

# theme=$(dirname $0)/scripts/${1:-base16-default-dark.sh}
# if [ -f $theme ]; then
#   # get the color declarations in said theme, assumes there is a block of text that starts with color00= and ends with new line
#   source $theme
#   eval $(awk '/^color00=/,/^$/ {print}' $theme | sed 's/#.*//')
# else
#   printf "No theme file %s found\n" $theme
# fi;
# ansi_mappings=(
#   Black
#   Red
#   Green
#   Yellow
#   Blue
#   Magenta
#   Cyan
#   White
#   Bright_Black
#   Bright_Red
#   Bright_Green
#   Bright_Yellow
#   Bright_Blue
#   Bright_Magenta
#   Bright_Cyan
#   Bright_White
# )
# colors=(
#   base00
#   base08
#   base0B
#   base0A
#   base0D
#   base0E
#   base0C
#   base05
#   base03
#   base08
#   base0B
#   base0A
#   base0D
#   base0E
#   base0C
#   base07
#   base09
#   base0F
#   base01
#   base02
#   base04
#   base06
# )
# for padded_value in `seq -w 0 21`; do
#   color_variable="color${padded_value}"
#   eval current_color=\$${color_variable}
#   current_color=$(echo ${current_color//\//} | tr '[:lower:]' '[:upper:]') # get rid of slashes, and uppercase
#   non_padded_value=$((10#$padded_value))
#   base16_color_name=${colors[$non_padded_value]}
#   current_color_label=${current_color:-unknown}
#   ansi_label=${ansi_mappings[$non_padded_value]}
#   block=$(printf "\x1b[48;5;${non_padded_value}m___________________________")
#   foreground=$(printf "\x1b[38;5;${non_padded_value}m$color_variable")
#   printf "%s %s %s %-30s %s\x1b[0m\n" $foreground $base16_color_name $current_color_label ${ansi_label:-""} $block
# done;
# if [ $# -eq 1 ]; then
#     printf "To restore current theme, source ~/.base16_theme or reopen your terminal\n"
# fi
