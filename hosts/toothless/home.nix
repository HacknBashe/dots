{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    stateVersion = "23.11"; # Please read the comment before changing.
    sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    font-awesome
    raleway

    discord
    spotify
  ];

  programs = {
    home-manager.enable = true;
  };

  home.file = {
    ".ssh/config" = {
      source = ../../files/config/ssh/config;
      target = ".ssh/config";
    };
    ".gitconfig.local" = {
      text = ''
        [user]
        name = Nick Hackford
        email = nick.hackford@gmail.com
      '';
      target = ".gitconfig.local";
    };
  };

  home.activation = {
    rsync-home-manager-applications = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
      apps_source="$genProfilePath/home-path/Applications"
      moniker="Home Manager Trampolines"
      app_target_base="${config.home.homeDirectory}/Applications"
      app_target="$app_target_base/$moniker"
      mkdir -p "$app_target"
      ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
    '';
  };
}
