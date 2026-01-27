{
  pkgs,
  config,
  inputs,
  ...
}: {
  home.packages = [inputs.opencode.packages.${pkgs.system}.default];

  home.file = {
    "opencode/opencode.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/${
        if config.isHubspot
        then "opencode-hubspot.json"
        else "opencode.json"
      }";
      target = ".config/opencode/opencode.json";
    };

    # Global agent rules
    "opencode/AGENTS.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/AGENTS.md";
      target = ".config/opencode/AGENTS.md";
    };

    # plugin: indicator.js
    "opencode/plugin/indicator.js" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/plugin";
      target = ".config/opencode/plugin";
      recursive = true;
    };
    "opencode/commands" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/commands";
      target = ".config/opencode/commands";
      recursive = true;
    };
  };
}
