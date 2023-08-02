{ lib
, fetchFromGitHub
, buildPythonPackage
, python
, rustPlatform
, pythonOlder
, breakpointHook
, makeSetupHook
, callPackage
, buildPackages
, cargo
, rust
, rustc
, maturin
, stdenv
, sphinx
}:
let
  ccForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
  cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
  ccForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
  cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
  rustBuildPlatform = rust.toRustTarget stdenv.buildPlatform;
  rustTargetPlatform = rust.toRustTarget stdenv.hostPlatform;
  rustTargetPlatformSpec = rust.toRustTargetSpec stdenv.hostPlatform;
  customBuildHook = callPackage({  }:
    makeSetupHook {
      name = "maturin-build-hook.sh";
      propagatedBuildInputs = [ cargo maturin rustc ];
      substitutions = {
        inherit ccForBuild ccForHost cxxForBuild cxxForHost
          rustBuildPlatform rustTargetPlatform rustTargetPlatformSpec;
      };
    } ./maturin-build-hook.sh) {};
in
buildPythonPackage rec {
  pname = "docleaf";
  version = "0.8.2";
  disabled  = pythonOlder "3.7";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "docleaf-labs";
    repo = pname;
    rev = version;
    hash = "sha256-HiBZDlnFgssm9cGaST8D0S3EL/AfEWlqkpZW8g90JP8=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src sourceRoot;
    name = "${pname}-${version}";
    hash = "sha256-ms2gXmr87jVRIuI+nlGAGOImfF6HsBUIgd92KMV8bXs=";
  };

  #cargoRoot = "rust";
  sourceRoot = "source/rust";

  nativeBuildInputs = [ rustPlatform.cargoSetupHook customBuildHook ];

  propagatedBuildInputs = [ sphinx ];
}
