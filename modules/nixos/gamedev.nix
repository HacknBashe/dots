{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unityhub
    monado
  ];
  services.udev.packages = [pkgs.monado];

  programs.adb.enable = true;
  users.users.nick.extraGroups = ["adbusers"];
}
