{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "nick";
  };
  environment.systemPackages = with pkgs; [
    yt-dlp
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
