{ stdenv, fetchurl, cmake, lib, pkgs, ... }:
let
  version = "9643a986dda97c6cb339d5c75c0eaa178d8317da";
in
stdenv.mkDerivation rec {
  name = "rimage";
  inherit version;
  src = pkgs.fetchgit {
    url = "https://github.com/thesofproject/rimage";
    fetchSubmodules = true;
    rev = "${version}";
    sha256 = "sha256-nx8TnlBcKXwsHNZTvGHK9SRh1izvp9MeG9buBhjNqsE=";
  };
  patches = [
    ./rimage.patch
  ];
  buildInputs = [
    pkgs.cmake
    pkgs.openssl
  ];
  configurePhase = ''
    cmake .
    '';
  installPhase = ''
    mkdir -p $out/bin
    cp rimage $out/bin
    cp -r $src/config $out/.
    '';
}
