{pkgs, ...}: {
  xdg.configFile."openxr/1/active_runtime.json" = {
    source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
    force = true;
  };
}
