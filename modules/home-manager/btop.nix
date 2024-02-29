{ config, pkgs, lib, ... }:

with config.lib.stylix.colors.withHashtag;

{
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      rounded_corners = true;
      vim_keys = true;
      background_update = false;
      presets = "cpu:0:default,mem:0:default";
      # TODO: add preset for gpu
    };
  };
}
