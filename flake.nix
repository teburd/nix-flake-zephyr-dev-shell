{
  description = "Development Environment for Zephyr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;
          config.permittedInsecurePackages = [
            "segger-jlink-qt4-794l"
          ];
        };
	llvm = pkgs.llvmPackages_latest;
        zephyr-sdk = pkgs.callPackage ./nix/zephyr-sdk.nix { version = "0.16.8"; };
        rimage = pkgs.callPackage ./nix/rimage.nix { };
        docleaf = ps: ps.callPackage ./nix/docleaf.nix { };
	sphinxcontrib-svg2pdfconverter = ps: ps.callPackage ./nix/sphinxcontrib-svg2pdfconverter.nix { };
        zephyr-python-packages = ps: with ps; [
            pip
            virtualenv
            pyocd
            python-magic
        ];
        zephyr-python = pkgs.python3.withPackages zephyr-python-packages;
      in
        {
          devShells.default = pkgs.multiStdenv.mkDerivation {
            name = "zephyr-devenv";
            nativeBuildInputs = with pkgs; [
              zephyr-sdk
              rimage
              zephyr-python 
              pkgs.tree
              pkgs.minicom
              pkgs.ninja
              pkgs.gperf
              pkgs.ccache
              pkgs.cmake
              pkgs.meson
              pkgs.dtc
              pkgs.gnumake
              pkgs.gdb
              pkgs.segger-jlink
              pkgs.nrf-command-line-tools
              pkgs.xxd
              pkgs.bison
              pkgs.flex
              pkgs.openocd
              pkgs.nixpkgs-fmt
              pkgs.doxygen
              pkgs.graphviz-nox
              pkgs.protobuf
              pkgs.pkg-config
              pkgs.libudev-zero
              pkgs.libudev0-shim
              pkgs.openssl
              pkgs.helix
              pkgs.clang-tools
              pkgs.glib
              rustup
            ];
            shellHook =''
              export ZEPHYR_SDK_INSTALL_DIR="${zephyr-sdk}"
              export ZEPHYR_BASE=/home/tburdick/z/zephyr
              export CAVS_HOST="rawr"
              export CAVS_RIMAGE="$ZEPHYR_BASE/../modules/audio/sof/rimage"
              export CAVS_KEY="$ZEPHYR_BASE/../modules/audio/sof/keys/otc_private_key_3k.pem"
              export CAVS_OLD_FLASHER=1
              export LD_LIBRARY_PATH="${pkgs.segger-jlink}/lib;${pkgs.file}/lib"
              exec fish
              '';
             hardeningDisable = [ "fortify" ];
             phases = [ "buildPhase" ];
             preferLocalBuild = true;
          };
        }
    );
}
