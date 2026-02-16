{pkgs, ...}: {
  # Mobile/Phosh configuration
  #services.xserver.enable = true;
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "nick";
    group = "users";
  };

  # XDG Portal for file chooser dialogs, screen sharing, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.phosh.default = ["gtk"];
  };

  # GNOME Keyring - unlocks secrets at login for Brave, git, etc.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.phosh.enableGnomeKeyring = true;

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
