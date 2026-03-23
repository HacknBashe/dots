{pkgs, ...}: let
  notes-app = pkgs.buildGoModule {
    pname = "notes-app";
    version = "0.1.0";
    src = ../../www/notes;
    vendorHash = "sha256-SMJpi1HBGpytjrtnN4O4z8kjyxIia24vfL4Zod8zjh4=";
    env.CGO_ENABLED = 0;

    meta = {
      description = "Personal notes web app";
      mainProgram = "notes-app";
    };
  };
in {
  systemd.services.notes-app = {
    description = "Notes Web App";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${notes-app}/bin/notes-app /home/nick/notes";
      User = "nick";
      Group = "users";
      Restart = "always";
      RestartSec = "5s";

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["/home/nick/notes"];
    };
  };
}
