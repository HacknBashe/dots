{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        ${builtins.readFile ../../files/config/wezterm/wezterm.lua}
      '';
      package = inputs.wezterm.packages.${pkgs.system}.default;
    };
  };
}
