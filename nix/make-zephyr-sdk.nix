{ stdenv, fetchurl, which, python38, autoPatchelfHook, lib, pkgs }:
let
  version = "0.15.0";
in
stdenv.mkDerivation {
  name = "zephyr-sdk";
  inherit version;
  src = fetchurl {
    url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64.tar.gz";
    hash = "sha256-mTwj3BBLfm4hGxow7D27+T9+Q10eEDtjyTxuM/M/QV8=";
  };
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    pkgs.makeWrapper
    python38
  ];
  installPhase = ''
	mkdir $out
	cp -r . $out
	wrapProgram $out/zephyr-sdk-x86_64-hosttools-standalone-0.9.sh --add-flags "-y -d $out"
	'';
}
