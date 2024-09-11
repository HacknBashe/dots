{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      rounded_corners = true;
      vim_keys = true;
      background_update = false;
      temp_scale = "fahrenheit";
      presets = "cpu:0:default,mem:0:default";
      # TODO: add preset for gpu
    };
  };
}
