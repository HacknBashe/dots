{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    pkgs.material-symbols
  ];

  home.file = {
    "caelestia" = {
      source = pkgs.fetchFromGitHub {
        owner = "caelestia-dots";
        repo = "shell";
        rev = "3a8b9c61be5ab4babfbd5b54db5069defc6e5ad3";
        sha256 = "F7wyDgofFaDAuaZjuUjSWVagT6x0iO48M3XvlAhEoWQ=";
      };
      target = ".config/quickshell/caelestia";
      recursive = true;
    };
  };
}
