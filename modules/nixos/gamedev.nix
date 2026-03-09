{pkgs, ...}: let
  # Combined .NET: 8 (Godot) + 9 (Android builds) + 10 runtime (csharp-ls)
  combinedDotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_8_0
    pkgs.dotnetCorePackages.sdk_9_0
    pkgs.csharp-ls.dotnet-runtime
  ];
  dotnetRoot = "${combinedDotnet}/share/dotnet";

  # Fix Godot TLS errors on the unwrapped binary
  # https://github.com/NixOS/nixpkgs/issues/454608
  godot-unwrapped = pkgs.godot-mono.unwrapped.overrideAttrs (old: {
    sconsFlags =
      old.sconsFlags
      ++ [
        "builtin_certs=false"
        "system_certs_path=/etc/ssl/certs/ca-certificates.crt"
      ];
  });

  # Re-wrap Godot with combined dotnet (stock wrapper hardcodes standalone .NET 8)
  godot-mono-fixed = pkgs.symlinkJoin {
    name = "godot-mono-${godot-unwrapped.version}";
    paths = [godot-unwrapped];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      for bin in $out/bin/godot*; do
        wrapProgram "$bin" \
          --set DOTNET_ROOT "${dotnetRoot}" \
          --prefix PATH : "${combinedDotnet}/bin"
      done
    '';
    passthru = {
      unwrapped = godot-unwrapped;
      dotnet-sdk = combinedDotnet;
    };
  };

  # Android SDK for Godot APK builds
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = ["34.0.0"];
    platformVersions = ["34"];
    includeEmulator = false;
    includeNDK = false;
    includeSystemImages = false;
    includeSources = false;
  };
  androidSdkPath = "${androidSdk.androidsdk}/libexec/android-sdk";
in {
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = with pkgs; [
    godot-mono-fixed
    combinedDotnet
    csharp-ls
    csharpier
    monado
    androidSdk.androidsdk
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
    ANDROID_HOME = androidSdkPath;
  };

  # Symlink SDK to ~/Android/Sdk (matches Godot editor settings)
  systemd.tmpfiles.rules = [
    "d /home/nick/Android 0755 nick users -"
    "L+ /home/nick/Android/Sdk - - - - ${androidSdkPath}"
  ];

  users.users.nick.extraGroups = ["adbusers"];
}
