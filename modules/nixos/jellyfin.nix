{pkgs, ...}: let
  ytDlpSyncScript = pkgs.writeShellScriptBin "yt-dlp-sync" (
    builtins.readFile ../../files/local/bin/jellyfin/yt-dlp-sync.sh
  );
in {
  services.jellyfin = {
    enable = true;
    openFirewall = false;
    user = "nick";
  };

  # VAAPI hardware acceleration for transcoding (Radeon 780M / RDNA3)
  hardware.graphics = {
    enable = true;
  };
  users.users.nick.extraGroups = ["render" "video"];

  environment.systemPackages = with pkgs; [
    yt-dlp
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    libva-utils # vainfo for debugging
  ];

  systemd.services.yt-dlp-sync = {
    description = "Download new YouTube episodes for Jellyfin";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    path = with pkgs; [yt-dlp util-linux coreutils bash];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ytDlpSyncScript}/bin/yt-dlp-sync";
      User = "nick";
      Group = "users";

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["/run/media/nick/Passport"];
    };
  };

  systemd.timers.yt-dlp-sync = {
    description = "Daily YouTube download sync";
    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Persistent = true;
    };
  };
}
