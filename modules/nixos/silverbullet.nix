{pkgs, config, ...}: let
  # Override SilverBullet to use newer version with tag.define support
  silverbullet = pkgs.stdenv.mkDerivation rec {
    pname = "silverbullet";
    version = "edge";

    src = pkgs.fetchzip {
      url = "https://github.com/silverbulletmd/silverbullet/releases/download/edge/silverbullet-server-linux-x86_64.zip";
      sha256 = "sha256-VgkBScG5KxtG/skWfbLw1q4I6EUwYjOeDSfVQijJCHk=";
      stripRoot = false;
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    installPhase = ''
      mkdir -p $out/bin
      cp silverbullet $out/bin/
      chmod +x $out/bin/silverbullet
    '';

    meta = {
      description = "Open-source, self-hosted, offline-capable Personal Knowledge Management";
      homepage = "https://silverbullet.md";
      license = pkgs.lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
    };
  };

  # Python with required packages for recurring tasks
  pythonWithPackages = pkgs.python3.withPackages (ps: [
    ps.dateparser
    ps.watchdog
  ]);

  # Script content from the dots files directory
  scriptFile = pkgs.writeText "task-processor.py" (
    builtins.readFile ../../files/local/bin/silverbullet/task-processor.py
  );

  # Wrapper script that runs the Python script
  taskProcessorScript = pkgs.writeShellScriptBin "silverbullet-task-processor" ''
    exec ${pythonWithPackages}/bin/python3 ${scriptFile}
  '';
in {
  systemd.services.silverbullet = {
    description = "SilverBullet Notes Server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    environment = {
      SB_HOSTNAME = "127.0.0.1"; # Only listen locally, Caddy handles external
      SB_PORT = "3001"; # 3000 is used by AdGuard
    };

    serviceConfig = {
      ExecStart = "${silverbullet}/bin/silverbullet /home/nick/notes";
      User = "nick";
      Group = "users";
      Restart = "always";
      RestartSec = "5s";

      # Load SB_USER from sops-decrypted secret
      EnvironmentFile = config.sops.secrets.silverbullet_auth.path;

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["/home/nick/notes"];
    };
  };

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
