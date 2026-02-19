{pkgs, ...}: let
  # Fix Godot TLS errors: https://github.com/NixOS/nixpkgs/issues/454608
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

  # .NET 8 (Godot) + exact .NET 10 runtime from csharp-ls
  combinedDotnet = pkgs.dotnetCorePackages.combinePackages [
    godot-mono-fixed.dotnet-sdk
    pkgs.csharp-ls.dotnet-runtime
  ];
in {
  environment.systemPackages = with pkgs; [
    godot-mono-fixed
    combinedDotnet
    csharp-ls
    csharpier
    monado
  ];

  environment.sessionVariables.DOTNET_ROOT = "${combinedDotnet}/share/dotnet";

  users.users.nick.extraGroups = ["adbusers"];
}
