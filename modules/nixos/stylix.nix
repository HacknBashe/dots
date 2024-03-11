{ config, pkgs, wallSmall, ... }: {
  stylix = {
    # TODO: Remove this or set to null once it's allowed
    # https://github.com/danth/stylix/issues/200
    image = pkgs.fetchurl {
      url =
        "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };

    polarity = "dark";

    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";

    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
        name = "SauceCodePro Nerd Font Mono";
      };
    };
  };
}
