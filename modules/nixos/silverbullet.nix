{pkgs, ...}: let
  # Python with required packages for recurring tasks
  pythonWithPackages = pkgs.python3.withPackages (ps: [
    ps.dateparser
    ps.watchdog
  ]);

  # Wrapper script that runs the Python script from the notes repo with prettier available
  taskProcessorScript = pkgs.writeShellScriptBin "silverbullet-task-processor" ''
    SCRIPT="/home/nick/notes/.scripts/task-processor.py"
    if [ ! -f "$SCRIPT" ]; then
      echo "task-processor.py not found at $SCRIPT" >&2
      exit 1
    fi
    export PATH="${pkgs.nodePackages.prettier}/bin:$PATH"
    exec ${pythonWithPackages}/bin/python3 "$SCRIPT"
  '';
in {
  # Task processor - transforms due syntax and handles recurring tasks
  systemd.services.silverbullet-task-processor = {
    description = "SilverBullet Task Processor";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${taskProcessorScript}/bin/silverbullet-task-processor";
      User = "nick";
      Group = "users";
      Restart = "always";
      RestartSec = "10s";

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["/home/nick/notes"];
    };
  };
}
