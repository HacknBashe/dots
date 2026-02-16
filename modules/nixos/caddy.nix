{config, pkgs, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts."http://hackford.us" = {
      serverAliases = [
        "hackford.us"
        "tv.hackford.us"
        "ads.hackford.us"
        "dev.hackford.us"
        "notes.hackford.us"
      ];

      extraConfig = ''
        @bare host hackford.us tv.hackford.us ads.hackford.us dev.hackford.us notes.hackford.us
        redir @bare https://www.{host}{uri} permanent
      '';
    };

    virtualHosts."https://hackford.us" = {
      serverAliases = [
        "www.hackford.us"
        "www.tv.hackford.us"
        "www.ads.hackford.us"
        "www.dash.hackford.us"
        "www.dev.hackford.us"
        "www.notes.hackford.us"
      ];

      extraConfig = ''
        @bare host hackford.us tv.hackford.us ads.hackford.us dev.hackford.us
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

        # Motion Canvas dev server
        @dev host www.dev.hackford.us
        handle @dev {
          import /run/caddy/basic_auth
          reverse_proxy localhost:9000
        }

        # SilverBullet notes
        @notes host www.notes.hackford.us
        handle @notes {
          reverse_proxy localhost:3001
        }

        handle {
          respond "404 – nothing here" 404
        }
      '';
    };
  };

  systemd.services.caddy.serviceConfig.ExecStartPre = let
    hashFile = config.sops.secrets.caddy_basic_auth_hash.path;
    script = pkgs.writeShellScript "caddy-gen-basic-auth" ''
      mkdir -p /run/caddy
      cat > /run/caddy/basic_auth <<EOF
      basic_auth {
        nick $(cat ${hashFile})
      }
      EOF
      chown caddy:caddy /run/caddy/basic_auth
      chmod 600 /run/caddy/basic_auth
    '';
  in ["!${script}"];

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
