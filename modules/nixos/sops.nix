{...}: {
  sops.age.keyFile = "/home/nick/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  sops.secrets.caddy_basic_auth_hash = {
    owner = "caddy";
  };
}
