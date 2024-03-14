{
  description = "Development Environment for Zephyr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-nrfconnect.url = "github:StarGate01/nixpkgs/nrfconnect";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-nrfconnect, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	inherit (nixpkgs) lib;
        nrfconnect-pr = import nixpkgs-nrfconnect {
            inherit system;
            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;
            config.permittedInsecurePackages = [
                "segger-jlink-qt4-794a"
            ];
        };
        overlay = final: prev: {
          inherit (nrfconnect-pr)
                  segger-jlink nrfconnect nrf-command-line-tools;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;
        };
	llvm = pkgs.llvmPackages_latest;
        zephyr-sdk = pkgs.callPackage ./nix/zephyr-sdk.nix { version = "0.16.4"; };
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
          devShells.default = pkgs.mkShell {
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
              pkgs.dtc
              pkgs.gnumake
              pkgs.gdb
              pkgs.segger-jlink
              pkgs.nrf-command-line-tools
              pkgs.xxd
              pkgs.openocd
              pkgs.nixpkgs-fmt
              pkgs.doxygen
              pkgs.graphviz-nox
              pkgs.protobuf
              pkgs.stdenv
              pkgs.pkg-config
              pkgs.libudev-zero
              pkgs.libudev0-shim
              pkgs.openssl
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
          };
        }
    );
}
