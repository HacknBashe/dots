{...}: {
  networking = {
    firewall = {
      allowedUDPPorts = [53];
    };
  };
  services.adguardhome = {
    enable = true;
    openFirewall = false;
    port = 3000;
    settings = {
      filtering = {
        rewrites = [
          {
            domain = "adguard.me";
            answer = "192.168.86.51";
          }
          {
            domain = "media.me";
            answer = "192.168.86.51";
          }
          {
            domain = "dash.me";
            answer = "192.168.86.51";
          }
        ];
      };
    };
  };
}
