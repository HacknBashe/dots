# my dotfiles

## NixOS

`sudo nixos-rebuild switch --flake ~/.config/dots`

## Home Manager

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel update

nix-shell '<home-manager>' -A install
nix-shell -p git

home-manager --extra-experimental-features 'nix-command flakes' switch --flake .#hack56224
```

## dconf
Home-manager needs dconf installed to work properly which doesn't come stock on Debian
```
sudo apt-get update
sudo apt install dconf-cli dconf-editor
```

## Docker
Home-manager cannot manage a root docker installation so it should be installed manually

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo apt install docker-compose
sudo usermod -aG docker azureuser                                                                                                                                                                 azureuser@ae-camel 18:34:23
```
