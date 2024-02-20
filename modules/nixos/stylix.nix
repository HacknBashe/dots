{ config, pkgs, ... }: {
  stylix = {
    image = /home/nick/Pictures/Walls/aurora.jpg;

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";

    fonts = {
      sizes.applications = 10;
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
        name = "SauceCodePro Nerd Font Mono";
      };
    };
  };
}
