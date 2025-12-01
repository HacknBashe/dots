{...}: {
  services.caddy = {
    enable = true;

    virtualHosts."https://hackford.us" = {
      serverAliases = [
        "www.hackford.us"
        "www.tv.hackford.us"
        "www.dash.hackford.us"
        "www.ads.hackford.us"
      ];

      extraConfig = ''
        @bare host hackford.us tv.hackford.us dash.hackford.us ads.hackford.us
        redir @bare https://www.{host}{uri} permanent

        # Main Jellyfin
        @jellyfin host www.hackford.us www.tv.hackford.us
        handle @jellyfin {
          reverse_proxy localhost:8096
        }

        @dash host www.dash.hackford.us
        handle @dash {
          reverse_proxy localhost:8000
        }

        @adguard host www.ads.hackford.us
        handle @adguard {
          reverse_proxy localhost:3000
        }

        handle {
          respond "404 – nothing here" 404
        }
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
