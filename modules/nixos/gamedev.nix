{pkgs, ...}: 
let
  # Fix TLS handshake errors by rebuilding with system certificates
  # See: https://github.com/NixOS/nixpkgs/issues/454608
  godot-mono-fixed = pkgs.godot-mono.overrideAttrs (final: prev: {
    unwrapped = prev.unwrapped.overrideAttrs (old: {
      sconsFlags = old.sconsFlags ++ [
        "builtin_certs=false"
        "system_certs_path=/etc/ssl/certs/ca-certificates.crt"
      ];
    });
  });
in
{
  environment.systemPackages = [
    godot-mono-fixed
  ];

  programs.adb.enable = true;
  users.users.nick.extraGroups = ["adbusers"];
}
