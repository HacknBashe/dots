{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "nick";
  SSID = "Toss a coin to your WiFi";
  SSIDpassword = "REDACTED";
  interface = "wlan0";
  hostname = "mushu";
in {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
    #"/mnt/passport" = {
    #device = "/dev/disk/by-label/Passport";
    #fsType = "ntfs";
    #};
  };

  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [interface];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    extraConfig = ''
      SetEnv TERM=xterm-256color
    '';
  };

  users = {
    users."${user}" = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
