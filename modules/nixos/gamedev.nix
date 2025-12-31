{pkgs, ...}: let
  # Fix TLS handshake errors by rebuilding with system certificates
  # See: https://github.com/NixOS/nixpkgs/issues/454608
  godot-mono-fixed = pkgs.godot-mono.overrideAttrs (final: prev: {
    unwrapped = prev.unwrapped.overrideAttrs (old: {
      sconsFlags =
        old.sconsFlags
        ++ [
          "builtin_certs=false"
          "system_certs_path=/etc/ssl/certs/ca-certificates.crt"
        ];
    });
  });

  # Combine Godot's .NET 8 SDK with .NET 9 so csharp-ls can target net8.0 projects
  combinedDotnet = pkgs.dotnetCorePackages.combinePackages [
    godot-mono-fixed.dotnet-sdk
    pkgs.dotnet-sdk_9
  ];
in {
  environment.systemPackages = with pkgs; [
    godot-mono-fixed
    combinedDotnet

    csharp-ls
    csharpier
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${combinedDotnet}/share/dotnet";
  };

  programs.adb.enable = true;
  users.users.nick.extraGroups = ["adbusers"];
}
