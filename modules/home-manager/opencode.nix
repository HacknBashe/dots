{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [opencode];

  home.file = {
    "opencode/opencode.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/opencode.json";
      target = ".config/opencode/opencode.json";
    };

    # plugin: indicator.js
    "opencode/plugin/indicator.js" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/plugin";
      target = ".config/opencode/plugin";
      recursive = true;
    };
  };
}
