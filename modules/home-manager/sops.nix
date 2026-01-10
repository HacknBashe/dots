{ config, lib, ... }:
let
  keyFilePath = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  keyFileExists = builtins.pathExists keyFilePath;
in {
  # Only configure sops if key file exists at build time
  config = lib.mkIf keyFileExists {
    sops.age.keyFile = keyFilePath;
    
    sops.secrets.brave_api_key = {
      sopsFile = ../../secrets/secrets.yaml;
      format = "yaml";
    };
    
    sops.secrets.github_token = {
      sopsFile = ../../secrets/secrets.yaml;
      format = "yaml";
    };

    # Generate shell script to export secrets as environment variables
    home.file.".zshrc.sops" = {
      text = ''
        # API Keys for CLI tools (managed by sops-nix)
        if [ -f "${config.sops.secrets.brave_api_key.path}" ]; then
          export BRAVE_API_KEY=$(cat ${config.sops.secrets.brave_api_key.path})
        fi
        if [ -f "${config.sops.secrets.github_token.path}" ]; then
          export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.sops.secrets.github_token.path})
        fi
      '';
      target = ".zshrc.sops";
    };
  };
}
