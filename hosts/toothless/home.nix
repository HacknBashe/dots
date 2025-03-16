{
  config,
  pkgs,
  lib,
  ...
}: {
  home.homeDirectory = "/Users/nick";

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
    ".gitconfig.local" = {
      text = ''
        [user]
        name = Nick Hackford
        email = nick.hackford@gmail.com
      '';
      target = ".gitconfig.local";
    };
  };

  launchd.agents.autoCommitNotes = {
    enable = true;
    config = {
      ProgramArguments = ["${config.home.homeDirectory}/.local/bin/auto_commit_notes.sh"];
      StandardOutPath = "/tmp/.auto_commit_notes.log";
      StandardErrorPath = "/tmp/.auto_commit_notes.log";
      StartCalendarInterval = [
        {Minute = 0;}
        {Minute = 10;}
        {Minute = 20;}
        {Minute = 30;}
        {Minute = 40;}
        {Minute = 50;}
      ];
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
