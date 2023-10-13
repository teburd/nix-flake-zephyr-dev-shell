{
  description = "Development Environment for Zephyr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;
        };
        zephyr-sdk = pkgs.callPackage ./nix/zephyr-sdk.nix { version = "0.16.1"; };
        rimage = pkgs.callPackage ./nix/rimage.nix { };
        docleaf = ps: ps.callPackage ./nix/docleaf.nix { };
        zephyr-python-packages = ps: with ps; [
          pyelftools
          pyyaml
          pykwalify
          canopen
          packaging
          progress
          psutil
          pylink-square
          requests
          anytree
          west
          cryptography
          intelhex
          click
          cbor
          jinja2
          sigrok
          pyocd
          # imgtool -- mcuboot's imagetool
          pyusb
          #twister deps
          ply
          pyserial
          tabulate
          GitPython
          natsort
          # doc deps
          sphinx
          sphinx-notfound-page
          sphinx-copybutton
          sphinx_rtd_theme
          sphinx-tabs
          sphinx-togglebutton
          pygments
          breathe
          (docleaf ps)
          # check copliance deps
          junitparser
          magic
          # protobuf modules
          protobuf
          grpcio-tools
        ];
        zephyr-python = pkgs.python3.withPackages zephyr-python-packages;
      in
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              zephyr-sdk
              rimage
              zephyr-python 
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
              pkgs.nixpkgs-fmt
              pkgs.pkgsi686Linux.gcc
              pkgs.doxygen
              pkgs.graphviz-nox
              pkgs.protobuf
            ];
            shellHook =''
              export ZEPHYR_SDK_INSTALL_DIR="${zephyr-sdk}"
              export ZEPHYR_BASE=/home/tburdick/z/zephyr
              export CAVS_HOST="rawr"
              export CAVS_RIMAGE="$ZEPHYR_BASE/../modules/audio/sof/rimage"
              export CAVS_KEY="$ZEPHYR_BASE/../modules/audio/sof/keys/otc_private_key_3k.pem"
              export CAVS_OLD_FLASHER=1
              '';
          };
        }
    );
}
