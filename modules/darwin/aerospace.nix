{
  config,
  lib,
  ...
}: {
  # TODO: Enable these services, replace homebrew versions
  services = {
    # aerospace = {
    #   enable = true;
    #   settings = lib.mkForce {};
    # };
    # sketchybar.enable = true;
    jankyborders = {
      enable = true;
      active_color = "0xff${builtins.substring 1 6 config.theme.colors.default.cyan}";
      inactive_color = "0xff${builtins.substring 1 6 config.theme.colors.default.white}";
      width = 10.0;
    };
  };
}
