{ config, pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile ./monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in {
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelModules = [ "sg" ];
    supportedFilesystems = [ "ntfs" ];
    loader = {
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
        device = "nodev";
        default = "saved";
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
  };

  networking.hostName = "nixos";
  networking.wireless.iwd.enable = true;
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
    opengl = { enable = true; };
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    videoDrivers = [ "nvidia" ];
    # desktopManager.gnome.enable = true;
    displayManager = {
      gdm.enable = true;
      sddm.enable = false;
      lightdm.enable = false;
      # autoLogin = {
      #   enable = true;
      #   user = "nick";
      # };
    };
  };
  systemd.tmpfiles.rules =
    [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}" ];
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    xdgOpenUsePortal = true;
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
  environment.etc = {
    "wireplumber/main.lua.d/51-device-setup.lua".text = ''
      alsa_monitor.rules = {
        {
          matches = {{{ "device.name", "equals", "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00" }}};
          apply_properties = {
            ["device.description"] = "Headset",
            ["device.nick"] = "Headset",
          },
        },
        {
          matches = {{{ "device.name", "equals", "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.2" }}};
          apply_properties = {
            ["device.description"] = "Soundbar",
            ["device.nick"] = "Soundbar",
          },
        },
        {
          matches = {{{ "node.name", "equals", "alsa_output.pci-0000_01_00.1.playback.7.0" }}};
          apply_properties = {
            ["node.description"] = "TV",
            ["node.nick"] = "TV",
            ["node.disabled"] = true,
          },
        },
        {
          matches = {{{ "node.name", "equals", "alsa_output.pci-0000_01_00.1.playback.3.0" }}};
          apply_properties = {
            ["node.disabled"] = true,
          },
        },
        {
          matches = {{{ "node.name", "equals", "alsa_output.pci-0000_01_00.1.playback.8.0" }}};
          apply_properties = {
            ["node.disabled"] = true,
          },
        },
        {
          matches = {{{ "node.name", "equals", "alsa_output.pci-0000_01_00.1.playback.9.0" }}};
          apply_properties = {
            ["node.disabled"] = true,
          },
        },
      }
    '';
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  services.printing.enable = true;

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
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  users.users.nick = {
    isNormalUser = true;
    description = "nick";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    android-tools
    alacritty
    brave
    btop
    cargo
    cava
    chntpw
    conda
    curl
    ctpv
    direnv
    distrobox
    # (pkgs.writeShellApplication {
    #   name = "discord";
    #   text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    # })
    # (pkgs.makeDesktopItem {
    #   name = "discord";
    #   exec = "discord";
    #   desktopName = "Discord";
    # })
    dos2unix
    dunst
    efibootmgr
    firefox
    fzf
    gcc
    git
    gimp
    gnumake
    go
    grim
    hyprland
    helvum
    jq
    inotify-tools
    libnotify
    libsecret
    lf
    makemkv
    neofetch
    neovim
    nixfmt
    obs-studio
    p7zip
    pulsemixer
    playerctl
    (python311.withPackages (ps: with ps; [ requests pyserial ]))
    qbittorrent
    qpwgraph
    ripgrep
    rustc
    spotify
    swaybg
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    tmux
    xfce.tumbler
    ungoogled-chromium
    vim
    vlc
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    webcord
    wezterm
    wl-clipboard
    wlogout
    wget
    wofi
    yarn
    yarn2nix
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
