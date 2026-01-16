{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = true;
    };
    settings = {
      theme_background = false;
      rounded_corners = true;
      vim_keys = true;
      background_update = false;
      temp_scale = "fahrenheit";
      presets = "cpu:0:default,mem:0:default,gpu0:0:default";
      shown_boxes = "cpu mem net proc gpu0";
    };
  };
}
