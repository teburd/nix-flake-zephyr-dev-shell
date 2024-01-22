{ lib
, fetchFromGitHub
, buildPythonPackage
, python
, pythonOlder
, makeSetupHook
, callPackage
, buildPackages
, stdenv
, sphinx
}:
buildPythonPackage rec {
  pname = "sphinxcontrib-svg2pdfconverter";
  version = "1.2.2";
  disabled  = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "missinglinkelectronics";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-E7x4FhkYRySZdifI/bfzd2ZwEyXPsugzJEe30o/mzSs=";
  };

  propagatedBuildInputs = [ sphinx ];
}
