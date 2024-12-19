{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.ags.packages.${pkgs.system}.agsFull
  ];

  home.file = {
    "ags" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeDirPath}.config/dots/files/config/ags";
      target = ".config/ags";
      recursive = true;
    };
  };
}
