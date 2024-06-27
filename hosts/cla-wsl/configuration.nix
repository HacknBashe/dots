# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, nixos-wsl, ... }:

let
  useYaml = false;
  templateRepo = config.lib.stylix.templates."base16-alacritty${
      if useYaml then "-yaml" else ""
    }";

  themeFile = config.lib.stylix.colors { inherit templateRepo; };
in {
  imports = [
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
    nixos-wsl.nixosModules.wsl
    ../../modules/nixos/core.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/stylix.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "nick";
  wsl.wslConf.network.generateResolvConf = false;

  networking.hostName = "cla-wsl";
  networking.nameservers = [ "8.8.8.8" ];

  services.gnome.gnome-keyring.enable = true;

  users.users.nick = {
    isNormalUser = true;
    description = "nick";
    extraGroups = [ "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [ ];

  system.activationScripts.windows = {
    text = ''
      echo "-------------------------------------------------------------"
      echo "------------ START MANUAL IDEMPOTENT SECTION ----------------"
      echo "-------------------------------------------------------------"

      echo
      echo "---------------------- Windows Configs ----------------------"

      copy() {
        local src="$1"
        local dest="$2"
        [[ -e "$src" ]] && {
            [[ -e $dest ]] && {
                echo "****** REMOVED: $dest exists, removing"
                rm $dest
            } 
            mkdir -p $(dirname $dest)

            cp "$src" "$dest" || {
                echo "****** ERROR: could not copy $src to $dest"
            }
            echo "****** COPIED: $dest copied"

        } || {
            echo "****** ERROR: source $src does not exist"
        }
      }

      copy "/home/nick/.config/dots/windows/.glaze-wm/config.yaml" \
              "/mnt/c/Users/hack56224/.glaze-wm/config.yaml"

      copy "/home/nick/.config/dots/windows/AppData/Roaming/alacritty/alacritty.toml" \
              "/mnt/c/Users/hack56224/AppData/Roaming/alacritty/alacritty.toml"

      copy "${themeFile}" \
              "/mnt/c/Users/hack56224/AppData/Roaming/alacritty/theme.toml"

      # WSL doesn't have permissions to copy to program files,
      if [ ! -f '/mnt/c/Program Files/Alacritty/conpty.dll' ]; then
          echo "WSL doesn't have necessary permissions, manually copy alacritty scroll fix files"
          explorer.exe "$(wslpath -w '/home/nick/.config/dots/windows/Program Files/Alacritty')"
          explorer.exe "$(wslpath -w '/mnt/c/Program Files/Alacritty')"
      fi

      echo "-------------------------------------------------------------"
      echo "------------ END MANUAL IDEMPOTENT SECTION ----------------"
      echo "-------------------------------------------------------------"
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
