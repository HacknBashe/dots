{
  config,
  pkgs,
  inputs,
  ...
}: let
  info = builtins.readFile ./info;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.extest.overlays.default
    ];
  };

  boot = {
    kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
    kernelModules = ["kvm-intel sg"];
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot.enable = true;
    };
    # USB audio quirk for Quad Cortex async clock handling
    # quirk_flags=16 = PLAYBACK_FIRST: Start playback stream first in implicit feedback mode
    extraModprobeConfig = ''
      options snd-usb-audio vid=0x152a pid=0x880a quirk_flags=16
    '';
  };

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

  networking.hostName = "meraxes";
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };

  services.avahi = {
    enable = true;
    allowInterfaces = ["enp4s0" "wlan0"];
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      input = {
        General = {
          UserspaceHID = true;
        };
      };
    };
  };
  services.blueman.enable = true;

  # /mnt/windows/Windows/System32/config
  # chntpw -e SYSTEM
  # > cd ControlSet001\Services\BTHPORT\Parameters\Keys

  # systemd.tmpfiles.rules = [
  #   "f+ /var/lib/bluetooth/00:28:F8:2F:1D:71/DC:2C:EE:3E:A6:75/info - - - - "
  #   "w+ /var/lib/bluetooth/00:28:F8:2F:1D:71/DC:2C:EE:3E:A6:75/info - - - - ${info}"
  # ];

  services.printing.enable = true;

  virtualisation.docker.enable = true;

  hardware = {
    graphics = {enable = true;};
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  security.polkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "soft";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "hard";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@audio";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Realtime priority for pulse audio is required for low-latency audio and to prevent xruns, especially with async USB audio (Quad Cortex)
  security.rtkit.enable = true;

  # Use performance CPU governor for low-latency audio
  powerManagement.cpuFreqGovernor = "performance";

  # Disable USB autosuspend for Quad Cortex (defensively prevernting audio issues)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="152a", ATTR{idProduct}=="880a", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"
  '';

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig = {
      pipewire = {
        # quantum=256 provides buffer headroom for async USB audio (Quad Cortex)
        # and fixes Rocksmith USB guitar adapter audio issues
        "10-clock-settings" = {
          "context.properties" = {
            "default.clock.min-quantum" = 64;
            "default.clock.quantum" = 256;
            "default.clock.rate" = 48000;
          };
        };
      };
    };
    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.writeTextDir
          "share/wireplumber/wireplumber.conf.d/51-device-setup.conf" ''
            monitor.alsa.rules = [
                # Device-level rules: set profile AND naming
                {
                   matches = [
                     {
                       device.name = "alsa_card.usb-Macronix_Razer_Barracuda_Pro_2.4_1234-00"
                     }
                   ]
                   actions = {
                     update-props = {
                       device.profile = "output:iec958-stereo+input:mono-fallback"
                       device.nick = "Headset"
                       device.description = "Headset"
                     }
                   }
                }
                {
                   matches = [
                     {
                       device.name = "alsa_card.usb-Generic_USB_Audio-00"
                     }
                   ]
                   actions = {
                     update-props = {
                       device.nick = "Soundbar"
                       device.description = "Soundbar"
                     }
                   }
                }
                {
                   matches = [
                     {
                       device.name = "alsa_card.usb-Neural_DSP_Quad_Cortex-00"
                     }
                   ]
                   actions = {
                     update-props = {
                       device.profile = "pro-audio"
                       device.nick = "Quad Cortex"
                       device.description = "Quad Cortex"
                     }
                   }
                }
                {
                   matches = [
                     {
                       device.name = "alsa_card.pci-0000_01_00.1"
                     }
                   ]
                   actions = {
                     update-props = {
                       device.nick = "Steam Link"
                       device.description = "Steam Link"
                     }
                   }
                }
                {
                   matches = [
                     {
                       device.name = "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00"
                     }
                   ]
                   actions = {
                     update-props = {
                       device.nick = "Dongle"
                       device.description = "Dongle"
                     }
                   }
                }
                # Node-level rules: disable unwanted nodes
                {
                   matches = [
                     {
                       node.name = "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1"
                     }
                   ]
                   actions = {
                     update-props = {
                       node.disabled = true
                     }
                   }
                }

                {
                   matches = [
                     {
                       node.nick = "HDA Intel PCH"
                     }
                   ]
                   actions = {
                     update-props = {
                       node.disabled = true
                     }
                   }
                }
             ]
          '')
      ];
    };
  };

  users.users = {
    nick = {
      isNormalUser = true;
      description = "nick";
      extraGroups = ["networkmanager" "wheel" "docker"];
      packages = with pkgs; [];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
