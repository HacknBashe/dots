{ config, pkgs, ... }:

with config.lib.stylix.colors.withHashtag;

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "base16";
      theme_background = false;
      rounded_corners = true;
      vim_keys = true;
      background_update = false;
      presets = "cpu:0:default,mem:0:default";
      # TODO: add preset for gpu
    };
  };

  home.file."base16.theme" = {
    target = ".config/btop/themes/base16.theme";
    text = ''
      #Bashtop base16 theme
      #by Nick

      # Colors should be in 6 or 2 character hexadecimal or single spaced rgb decimal: "#RRGGBB", "#BW" or "0-255 0-255 0-255"
      # example for white: "#FFFFFF", "#ff" or "255 255 255".

      # All graphs and meters can be gradients
      # For single color graphs leave "mid" and "end" variable empty.
      # Use "start" and "end" variables for two color gradient
      # Use "start", "mid" and "end" for three color gradient
                  
      # Main background, empty for terminal default, need to be empty if you want transparent background
      theme[main_bg]="${base00}"

      # Main text color
      theme[main_fg]="${base07}"

      # Title color for boxes
      theme[title]="${base07}"

      # Higlight color for keyboard shortcuts
      theme[hi_fg]="${base03}"

      # Background color of selected item in processes box
      theme[selected_bg]="${base01}"

      # Foreground color of selected item in processes box
      theme[selected_fg]="${base07}"

      # Color of inactive/disabled text
      theme[inactive_fg]="${base02}"

      # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
      theme[graph_text]="${base05}"

      # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
      theme[proc_misc]="${base06}"

      # Cpu box outline color
      theme[cpu_box]="${base03}"

      # Memory/disks box outline color
      theme[mem_box]="${base03}"

      # Net up/down box outline color
      theme[net_box]="${base03}"

      # Processes box outline color
      theme[proc_box]="${base03}"

      # Box divider line and small boxes line color
      theme[div_line]="${base03}"

      # Temperature graph colors
      theme[temp_start]="${base0B}"
      theme[temp_mid]="${base0A}"
      theme[temp_end]="${base08}"

      # CPU graph colors
      theme[cpu_start]="${base0B}"
      theme[cpu_mid]="${base0A}"
      theme[cpu_end]="${base08}"

      # Mem/Disk free meter
      theme[free_start]="${base0B}"
      theme[free_mid]="${base0A}"
      theme[free_end]="${base08}"

      # Mem/Disk cached meter
      theme[cached_start]="${base0B}"
      theme[cached_mid]="${base0A}"
      theme[cached_end]="${base08}"

      # Mem/Disk available meter
      theme[available_start]="${base0B}"
      theme[available_mid]="${base0A}"
      theme[available_end]="${base08}"

      # Mem/Disk used meter
      theme[used_start]="${base0B}"
      theme[used_mid]="${base0A}"
      theme[used_end]="${base08}"

      # Download graph colors
      theme[download_start]="${base0B}"
      theme[download_mid]="${base0A}"
      theme[download_end]="${base08}"

      # Upload graph colors
      theme[upload_start]="${base0B}"
      theme[upload_mid]="${base0A}"
      theme[upload_end]="${base08}"
    '';
  };
}
