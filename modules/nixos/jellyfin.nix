{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = false;
    user = "nick";
  };
  environment.systemPackages = with pkgs; [
    yt-dlp
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
