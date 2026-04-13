{ pkgs ? import <nixpkgs> {} }:

let
  occt = pkgs.opencascade-occt;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.haskell.packages.ghc98.ghc
    occt
    pkgs.zlib
    pkgs.cacert
  ];

  env = {
    C_INCLUDE_PATH = "${occt}/include/opencascade";
    CPLUS_INCLUDE_PATH = "${occt}/include/opencascade";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    LANG = "C.UTF-8";
  };
}
