{ stdenv, fetchurl, which, autoPatchelfHook, lib, pkgs }:
let
  version = "0.16.1";
in
stdenv.mkDerivation {
  name = "zephyr-sdk";
  inherit version;
  src = fetchurl {
    url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64.tar.xz";
    hash = "sha256-UTONUapM6iUWZBzg2dwLUbdjd58A3EVkorwN1xPfIsc=";
  };
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    pkgs.makeWrapper
    pkgs.cmake
    pkgs.which
    pkgs.python38
  ];
  dontConfigure=true;
  buildPhase = ''
       ./zephyr-sdk-x86_64-hosttools-standalone-0.9.sh -y -d .
       '';
  installPhase = ''
        cp -r . $out
        mkdir -p $out/bin
        ln -s $out/*/bin/* $out/bin/.
        '';
}
