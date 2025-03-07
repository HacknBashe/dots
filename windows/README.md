```sh
winget install ghostty brave chrome discord spotify win32yank
```

- Download [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)

```sh
wsl install --no-distribution
wsl --import NixOS .\NixOS\ nixos-wsl.tar.gz --version 2
wsl --set-default NixOS
```
