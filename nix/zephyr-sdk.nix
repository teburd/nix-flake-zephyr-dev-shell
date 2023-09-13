{ stdenv, fetchurl, which, autoPatchelfHook, patchelf, lib, pkgs, version ? "0.16.1" }:
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
  preBuild = ''
  '';
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

  # a number of shared libs do not have the runpath correctly set, so we need to fix that
#  preFixup = ''
#       patchelf --set-rpath $out/sysroot/x86_64-pokysdk/lib $out/sysroot/x86_64/pokysdk/lib/libusb-1.0.so.0
#       '';

  buildPhase = ''
       ./zephyr-sdk-x86_64-hosttools-standalone-0.9.sh -y -d .
       '';

  installPhase = ''
        cp -r . $out
        mkdir -p $out/bin
        ln -s $out/*/bin/* $out/bin/.
        ln -s $out/sysroots/x86_64-pokysdk-linux/usr/bin/qemu-* $out/bin/
        rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libc*
        rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libpthread*
        '';
}
