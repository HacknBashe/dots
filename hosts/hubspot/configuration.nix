{...}: let
  user = "nhackford";
in {
  services.nix-daemon.enable = true;
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  nix.settings.experimental-features = "nix-command flakes";

  security.pki.certificateFiles = [
    "/etc/nix/certs.pem"
  ];
  nix.settings.ssl-cert-file = "/etc/nix/certs.pem";
  environment.variables = {
    "NIX_SSL_CERT_FILE" = "/etc/nix/certs.pem";
    "SSL_CERT_FILE" = "/etc/nix/certs.pem";
    "REQUEST_CA_BUNDLE" = "/etc/nix/certs.pem";
  };
  security.sudo.extraConfig = ''
    Defaults env_keep += "NIX_SSL_CERT_FILE"
    Defaults env_keep += "SSL_CERT_FILE"
    Defaults env_keep += "REQUEST_CA_BUNDLE"
  '';

  programs.zsh.enable = true;

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  # homebrew = {
  #   enable = true;
  #   casks = [
  #     "nikitabobko/tap/aerospace"
  #     "intellij-idea-ce"
  #     "karabiner-elements"
  #     "visual-studio-code"
  #   ];
  #   forumlae = [
  #     brew tap FelixKratz/formulae
  #     brew install borders
  #     brew tap FelixKratz/formulae
  #     brew install sketchybar
  #     "switchaudio-osx"

  #     "koekeishiya/formulae/yabai"
  #     "koekeishiya/formulae/shkd"
  #   ];
  # };

  system.stateVersion = 5;
}
