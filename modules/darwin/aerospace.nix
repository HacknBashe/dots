{
  config,
  lib,
  ...
}: {
  services = {
    aerospace = {
      enable = true;
    };
    sketchybar.enable = true;
    jankyborders = {
      enable = true;
      active_color = "0xff${builtins.substring 1 6 config.theme.colors.base16.base07}";
      inactive_color = "0x00${builtins.substring 1 6 config.theme.colors.base16.base02}";
      width = 10.0;
    };
  };
  # Manually edit launchd service because it keeps adding a config file even with no settings passed in
  launchd.user.agents = {
    aerospace = lib.mkForce {
      command = "${config.services.aerospace.package}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}
