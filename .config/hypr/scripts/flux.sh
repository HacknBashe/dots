# Run the command and capture the output
output=$(hyprctl getoption -j decoration:screen_shader | jq -r '.str')

# Substring to check for
substring="blue-light"

# Check if the output contains the substring
if [[ $output == *"$substring"* ]]; then
    echo "The output contains '$substring'."
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
else
    echo "The output does not contain '$substring'."
    hyprctl keyword decoration:screen_shader $HOME/.config/hypr/shaders/blue-light-filter.glsl
fi
