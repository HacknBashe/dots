{...}: {
  networking = {
    firewall = {
      allowedUDPPorts = [53];
    };
  };
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 3000;
  };
}
