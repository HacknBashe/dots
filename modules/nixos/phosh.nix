{pkgs, ...}: {
  # Mobile/Phosh configuration
  #services.xserver.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "nick";
    group = "users";
  };

  # Mobile-friendly packages
  environment.systemPackages = with pkgs; [
    phosh
    squeekboard # On-screen keyboard
    gnome-settings-daemon
    gnome-control-center
  ];

  # Enable touch and mobile hardware support
  hardware.graphics.enable = true;

  # Mobile power management
  services.upower.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # Mobile networking
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
}
