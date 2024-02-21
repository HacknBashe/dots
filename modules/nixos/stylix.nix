{ config, pkgs, ... }: {
  stylix = {
    image = /home/nick/Pictures/Walls/glowshroom-large.jpg;
    polarity = "dark";

    # base16Scheme =
    #   "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";

    fonts = {
      sizes.applications = 10;
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
        name = "SauceCodePro Nerd Font Mono";
      };
    };
  };
}
