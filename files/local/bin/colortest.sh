#!/usr/bin/env bash

echo -e "\033[30m1    Base00  ██ "   # Black
echo -e "\033[91m11   Base01  ██ "  # Bright Red
echo -e "\033[92m12   Base02  ██ "  # Bright Green
echo -e "\033[90m9    Base03  ██ "   # Bright Black
echo -e "\033[93m13   Base04  ██ "  # Bright Yellow
echo -e "\033[97m8    Base05  ██ "   # White
echo -e "\033[95m14   Base06  ██ "  # Bright Magenta
echo -e "\033[97m16   Base07  ██ "  # Bright White
echo -e "\033[31m2    Base08  ██ "   # Red
echo -e "\033[91m10   Base09  ██ "  # Bright Red
echo -e "\033[33m4    Base0A  ██ "   # Yellow
echo -e "\033[32m3    Base0B  ██ "   # Green
echo -e "\033[96m7    Base0C  ██ "   # Cyan
echo -e "\033[34m5    Base0D  ██ "   # Blue
echo -e "\033[35m6    Base0E  ██ "   # Magenta
echo -e "\033[96m15   Base0F  ██ "  # Bright Cyan

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
