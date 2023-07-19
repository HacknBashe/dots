{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

 boot.loader = {
   # systemd-boot.enable = true;
   efi = {
     canTouchEfiVariables = true;
     efiSysMountPoint = "/boot/efi";
   };
   grub = {
     enable = true;
     efiSupport = true;
     useOSProber = true;
     copyKernels = true;
     # efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
     # device = "/dev/nvme0n1";
     device = "nodev";
     default = "3";
     extraEntriesBeforeNixOS = true;
     extraEntries = ''
       menuentry "UEFI Firmware Settings" {
         fwsetup
       }
       menuentry "Reboot" {
         reboot
       }
       menuentry "Power" {
         halt
       }
     '';
   };
 };

  networking.hostName = "nixos";
  # networking.wireless.enable = true;
  networking.wireless.iwd.enable = true;
  # networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  hardware = {
      opengl = {
          enable = true;
      };
      nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
  };

  # Enable window and display manager
  programs.hyprland.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    videoDrivers = ["nvidia"];
    displayManager = {
      gdm.enable = true;
      #autoLogin = {
      #  enable = true;
      #  user = "nick";
      #};
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Configure shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  security.sudo.configFile = ''
	Defaults !always_set_home, !set_home
	Defaults env_keep+=HOME
  '';

  nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };
  };

  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nick = {
    isNormalUser = true;
    description = "nick";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    android-tools
    alacritty
    brave
    btop
    cava
    gnumake
    conda
    curl
    ctpv
    #discord
    (pkgs.writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
    })
    dos2unix
    efibootmgr
    firefox
    fzf
    gcc
    git
    go
    hyprland
    helvum
    inotify-tools
    lf
    neofetch
    neovim
    pavucontrol
    (python311.withPackages(ps: with ps; [requests pyserial]))
    qbittorrent
    qpwgraph
    ripgrep
    spotify
    swaybg
    xfce.thunar
    tmux
    vim
    waybar
    wl-clipboard
    wofi
    wget
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
