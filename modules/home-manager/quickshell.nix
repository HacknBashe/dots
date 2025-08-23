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
        rev = "3a5f615f509fbff895846ecd3a606eb2c7192cf8";
        sha256 = "EE9clP2JXbImNr6wjDVk1JumBr8RaMecvi7G07Sbuyg=";
      };
      target = ".config/quickshell/caelestia";
      recursive = true;
    };
  };
}
