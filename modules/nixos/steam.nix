{pkgs, ...}: {
  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    enable = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      wivrn
    ];
  };

  hardware.steam-hardware.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true; # Opens UDP ports 9944, etc.
    defaultRuntime = true;
    autoStart = true;
    package = pkgs.wivrn.override {cudaSupport = true;}; # If NVIDIA; remove for AMD
  };
}
