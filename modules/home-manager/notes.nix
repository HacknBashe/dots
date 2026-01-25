{
  config,
  pkgs,
  lib,
  ...
}: {
  # Linux: Systemd timer to run every 10 minutes
  systemd.user.timers.syncNotes = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Sync notes timer";
    };
    Timer = {
      OnCalendar = "*:0/10";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  # Linux: Systemd service to sync notes using the existing script
  systemd.user.services.syncNotes = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Sync notes service";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/global/auto_commit_notes.sh";
      StandardOutput = "journal";
      StandardError = "journal";
      Environment = "PATH=${pkgs.bash}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:${pkgs.openssh}/bin";
    };
  };

  # macOS: Launchd agent to run every 10 minutes
  launchd.agents.autoCommitNotes = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = ["${config.home.homeDirectory}/.local/bin/global/auto_commit_notes.sh"];
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
}
