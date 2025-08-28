{pkgs, ...}: {
  services.caddy = {
    enable = true;
    virtualHosts."http://67.241.164.18" = {
      extraConfig = ''
        reverse_proxy localhost:8096
      '';
    };
    virtualHosts."http://adguard.me" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
    virtualHosts."http://media.me" = {
      extraConfig = ''
        reverse_proxy localhost:8096
      '';
    };
    virtualHosts."http://dash.me" = {
      extraConfig = ''
        reverse_proxy localhost:8000
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  # Optional: Add some security headers and access logging
  services.caddy.globalConfig = ''
    # Global options
    servers {
      protocols h1 h2
    }
  '';
}
