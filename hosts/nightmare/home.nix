{pkgs, ...}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";
  home.stateVersion = "25.05";
  home.file = {
    # Parental apps toggle script
    ".local/bin/toggle_parental_apps.sh" = {
      source = ./toggle_parental_apps.sh;
      executable = true;
    };
  };
}
