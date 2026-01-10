{...}: {
  services.caddy = {
    enable = true;

    virtualHosts."http://hackford.us" = {
      serverAliases = [
        "hackford.us"
        "tv.hackford.us"
        "ads.hackford.us"
      ];

      extraConfig = ''
        @bare host hackford.us tv.hackford.us ads.hackford.us
        redir @bare https://www.{host}{uri} permanent
      '';
    };

    virtualHosts."https://hackford.us" = {
      serverAliases = [
        "www.hackford.us"
        "www.tv.hackford.us"
        "www.ads.hackford.us"
        "www.dash.hackford.us"
      ];

      extraConfig = ''
        @bare host hackford.us tv.hackford.us ads.hackford.us
        redir @bare https://www.{host}{uri} permanent

        # Main
        @main host www.dash.hackford.us
        handle @main {
          root * /var/www
          file_server
        }

        # Jellyfin
        @jellyfin host www.tv.hackford.us
        handle @jellyfin {
          reverse_proxy localhost:8096
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

  system.activationScripts.copyDashStatic = {
    text = ''
      mkdir -p /var/www
      cp -r ${../../www}/* /var/www/
      chown -R caddy:caddy /var/www/
    '';
    deps = [];
  };
}
