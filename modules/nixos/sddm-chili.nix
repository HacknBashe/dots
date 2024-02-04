{ pkgs }:

let
  imgLink =
    "https://img.freepik.com/free-photo/galactic-night-sky-astronomy-science-combined-generative-ai_188544-9656.jpg?w=1380&t=st=1706838336~exp=1706838936~hmac=7925be6f95e32a95be2ee6879a750fe73d994efe0d487bd63a88138054a648ec";
  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "1h8x9m5x7k8f3m7l5n5x4s7z6r2s7b6s5k5x7z7m7z7h5x8k3";
  };
in pkgs.stdenv.mkDerivation {
  name = "sddm-chili";
  src = pkgs.fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-chili";
    rev = "6516d50176c3b34df29003726ef9708813d06271";
    sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
  };
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
  '';
  # cd $out/
  # rm Background.jpg
  # cp -r ${image} $out/Background.jpg
}
