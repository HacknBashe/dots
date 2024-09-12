{
  pkgs,
  config,
}:
pkgs.stdenv.mkDerivation {
  name = "sddm-theme";
  src = pkgs.fetchFromGitHub {
    owner = "stepanzubkov";
    repo = "where-is-my-sddm-theme";
    rev = "1457631fa87dd4139d45bd9ef38359c13bf0b269";
    sha256 = "0wm4zgmivh5jnq90df2ikl1zvmvd19bvmldh2s5syg1yk0d7xl9q";
  };
  installPhase = ''
        mkdir -p $out
        cp -R ./where_is_my_sddm_theme/* $out/
        cd $out/
        cp -r ${config.theme.wallLarge} $out/Background.jpg
        rm theme.conf
    cat <<EOL > theme.conf
    [General]
    passwordCharacter=•
    passwordFontSize=96
    sessionsFontSize=24
    usersFontSize=48
    background=Background.jpg
    backgroundFill=#000000
    backgroundFillMode=aspect
    cursorColor=#FFFFFF
    EOL
  '';
}
