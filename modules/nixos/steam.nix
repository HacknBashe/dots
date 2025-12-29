{
  pkgs,
  inputs,
  ...
}: {
  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    enable = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      wivrn
    ];
  };

  hardware.steam-hardware.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true; # Opens UDP ports 9944, etc.
    defaultRuntime = true;
    autoStart = true;
    package = (pkgs.wivrn.overrideAttrs (old: {
      src = inputs.wivrn;
      version = "25.12";

      # Update Monado to the version expected by WiVRn v25.12
      monado = pkgs.applyPatches {
        inherit (old.monado) patches postPatch;
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "monado";
          repo = "monado";
          rev = "20e0dacbdd2de863923790326beec76e848b056a";
          hash = "sha256-wiXdMgp3bKW17KqLnSn6HHhz7xbQtjp4c3aU7qp+2BE=";
        };
      };

      # Remove postUnpack check since we're using a flake source
      postUnpack = null;

      # Disable separate debug info
      separateDebugInfo = false;

      # Add extra dependencies for development features
      buildInputs =
        old.buildInputs
        ++ (with pkgs; [
          sdl2-compat
          librsvg
          libpng
          libarchive
        ]);

      nativeBuildInputs =
        old.nativeBuildInputs
        ++ (with pkgs; [
          util-linux
        ]);
    })).override {cudaSupport = true;}; # If NVIDIA; remove for AMD
  };

  environment.systemPackages = with pkgs; [
    bs-manager
    heroic
    obsidian
    protonup-qt
    prismlauncher
  ];
}
