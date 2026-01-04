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
      # Use ANSI cyan for active border, mid-tone background for inactive
      active_color = "0xff${builtins.substring 1 6 config.theme.colors.default.cyan}";
      inactive_color = "0x00${builtins.substring 1 6 config.theme.colors.indexed.four}";
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
