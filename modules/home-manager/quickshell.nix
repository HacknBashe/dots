{
  pkgs,
  inputs,
  config,
  ...
}: {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.caelestia-shell.packages.${pkgs.system}.default
  ];

  home.file = {
    "nick" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/quickshell/nick";
      target = ".config/quickshell/nick";
      recursive = true;
    };
  };

  # Set environment variable for lock command
  home.sessionVariables = {
    LOCK_COMMAND = config.lockCommand;
  };
}
