```sh
winget install alacritty brave chrome discord spotify win32yank
```

* [Alacritty Mouse Fix](https://github.com/wez/wezterm/tree/main/assets/windows/conhost)
    * Download OpenConsole.exe and conpty.dll, place in Program Files/Alacritty for mouse to work
* Download [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)

```sh
wsl install --no-distribution
wsl --import NixOS .\NixOS\ nixos-wsl.tar.gz --version 2
wsl --set-default NixOS
```
"C:\Program Files\WSL\wslg.exe" -d Ubuntu --cd "~" -- env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/ubuntu-desktop-installer_ubuntu-desktop-installer.desktop /snap/bin/ubuntu-desktop-installer
