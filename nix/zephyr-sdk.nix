{ stdenv, fetchurl, which, autoPatchelfHook, lib, pkgs, version ? "0.16.1" }:
let
  versions = {
    "0.16.1" = {
      hash = "sha256-UTONUapM6iUWZBzg2dwLUbdjd58A3EVkorwN1xPfIsc="; 	
    };
    "0.16.0" = {
      hash = "sha256-Y/0qcP6UHJLMkr8T9aUP94XAvRBRRg7GYVQs0QuQUs0=";
    };
  }; 
in
stdenv.mkDerivation {
  name = "zephyr-sdk";
  inherit version;
  src = fetchurl {
    url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64.tar.xz";
    hash = versions.${version}.hash;
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
