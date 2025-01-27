{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.etc."nix/vars.ts".text = ''
    export const MONITOR_1_COMMAND = "${config.monitor1Command}";
    export const MONITOR_2_COMMAND = "${config.monitor2Command}";
    export const MONITOR_3_COMMAND = "${config.monitor3Command}";
  '';
}
