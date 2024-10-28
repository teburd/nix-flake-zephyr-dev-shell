{ stdenv, fetchurl, which, autoPatchelfHook, patchelf, lib, pkgs, version ? "0.16.3" }:
let
  versions = {
    "0.16.8" = {
      hash = "sha256-y05AEnUeRSaq8eweirm03tVoHi4BcRtk96G1Gf99vGo=";
    };
    "0.16.4" = {
      hash = "sha256-0BmqqjQlyoQliCm1GOsfhy6XNu1Py7bZQIxMs3zSfjE=";
    };
    "0.16.3" = {
      hash = "sha256-nrVX0J0OnU4LJ/gWBSUKBhi7kp5COYfvQBZ6MwfIImI=";
    };
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
    pkgs.python39
  ];
  dontConfigure=true;

  # The sdk depends on python38 for the various gdb-py binaries for each arch, 3.8 is long since unsupported
  # and nixos 24.05+ dropped it, so patch elf replacing the so dependency with the python3 package libpython3.x.so.1.0
  preFixup = ''
       find $out -name "*-gdb-py" | xargs patchelf --replace-needed libpython3.8.so.1.0 ${pkgs.python39}/lib/libpython3.9.so.1.0 
       '';

  buildPhase = ''
       ./zephyr-sdk-x86_64-hosttools-standalone-0.9.sh -y -d .
       '';

  installPhase = ''
        cp -r . $out
        mkdir -p $out/bin
        ln -s $out/*/bin/* $out/bin/.
        ln -s $out/sysroots/x86_64-pokysdk-linux/usr/bin/qemu-* $out/bin/
	# remove duplicate shared libs for C, use the system libraries 
        rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libc*
	rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libdl*
	rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libm*
        rm -f $out/sysroots/x86_64-pokysdk-linux/lib/libpthread*
        rm -f $out/sysroots/x86_64-pokysdk-linux/lib/librt*
        '';
}
