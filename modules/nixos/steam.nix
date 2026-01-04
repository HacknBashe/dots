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

  # Bind mount for exFAT external drive Steam library
  #
  # PROBLEM: The external drive "Spinner" is formatted as exFAT, which does not
  # support symbolic links. When Proton/Wine creates game prefixes (compatdata),
  # it needs to create symlinks for Windows directory structures like:
  #   "Local Settings/Application Data" -> "AppData/Local"
  # Without symlink support, games fail to launch with errors like:
  #   PermissionError: [Errno 1] Operation not permitted: '../AppData/Local'
  #
  # SOLUTION: Store compatdata (Wine prefixes) on the ext4 /home partition where
  # symlinks ARE supported, then bind mount it to where Steam expects it on the
  # exFAT drive. This allows:
  #   - Game files to remain on the large exFAT external drive
  #   - Wine prefixes (compatdata) to live on ext4 where symlinks work
  #   - Steam to see everything in the expected locations
  #
  # AUTOMOUNT: The bind mount activates automatically when Steam accesses the
  # compatdata directory. This handles drive unplug/replug scenarios gracefully.
  # The mount waits for the external drive to be available before activating.
  systemd.mounts = [{
    description = "Bind mount Steam compatdata from ext4 to exFAT drive";
    what = "/home/nick/.local/share/steam-external-compatdata/Spinner";
    where = "/run/media/nick/Spinner/SteamLibrary/steamapps/compatdata";
    type = "none";
    options = "bind";
    # Wait for the external drive to be mounted first
    requires = [ "run-media-nick-Spinner.mount" ];
    after = [ "run-media-nick-Spinner.mount" ];
  }];

  systemd.automounts = [{
    description = "Automount Steam compatdata bind mount";
    where = "/run/media/nick/Spinner/SteamLibrary/steamapps/compatdata";
    wantedBy = [ "multi-user.target" ];
  }];
}
