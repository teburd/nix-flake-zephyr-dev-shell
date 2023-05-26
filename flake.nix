{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;
            overlays = [
              devshell.overlays.default
            ];
          };
          zephyr-sdk = pkgs.callPackage ./nix/zephyr-sdk.nix { };
          rimage = pkgs.callPackage ./nix/rimage.nix { };
          python-packages = pkgs.python3.withPackages (p: builtins.attrValues {
            inherit (p)
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
              # imgtool -- mcuboot's imagetool
              pip
              pyusb
              #twister deps
              ply
              pyserial
              tabulate
              GitPython
              # check copliance deps
              junitparser
              magic;
          });
        in
          pkgs.devshell.mkShell {
            name = "zephyr-" + zephyr-sdk.version;
            motd = "Zephyr Development with Nix\n" +
                   " SDK: ${zephyr-sdk}";
            packages = [
              zephyr-sdk
              rimage
              python-packages
              pkgs.minicom
              pkgs.pyocd
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
            ];
            env = [
              { name = "ZEPHYR_SDK_INSTALL_DIR"; value = "${zephyr-sdk}"; }
              { name = "PYTHONPATH"; eval = "${python-packages}/lib/python3.9/site-packages:$PYTHONPATH"; }
              { name = "LD_LIBRARY_PATH"; eval = "${pkgs.libusb-compat-0_1}/lib:$LD_LIBRARY_PATH"; }
            ];
          };
    });
}
