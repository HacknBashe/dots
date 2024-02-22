{ config, pkgs, wallSmall, ... }: {
  stylix = {
    image = wallSmall;
    polarity = "dark";

    # base16Scheme =
    #   "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";

    fonts = {
      sizes.applications = 10;
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
        name = "SauceCodePro Nerd Font Mono";
      };
    };
  };
}
