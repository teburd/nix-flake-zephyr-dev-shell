{
  description = "A Zephyr dev shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils/master";
    devshell.url = "github:numtide/devshell/master";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, devshell }:
    let
      local-pythonpkgs = ".pythonpkgs";
      mkZephyrShell = pkgs:
        let 
        zephyr-sdk = pkgs.zephyrSdk;
        python-packages = pkgs.python3.withPackages (p: builtins.attrValues {
            inherit (p)
              pyelftools
              pyyaml
              pykwalify
              canopen
              packaging
              progress
              psutil
              anytree
              west
              cryptography
              intelhex
              click
              cbor
              jinja2
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
            # TODO: find a way to add this to the overlay
            #imgtool = (p.callPackage ./nix/python-imgtool.nix { });
          });
        in
        pkgs.devshell.mkShell {
	  name = "zephyr-sdk-" + zephyr-sdk.version;
          motd = "Zephyr Development with Nix\n" +
		             " SDK: ${zephyr-sdk}";
          packages = builtins.attrValues {
            inherit
              zephyr-sdk
              python-packages
              ;
            inherit (pkgs)
              binutils
              ninja
              gperf
              ccache
              cmake
              dtc
              gnumake
              # debug utilities
              gdb;
            inherit (pkgs.stdenv) cc;
            inherit (pkgs.unixtools) xxd;
            openssl-dev = pkgs.openssl.dev;
            sqlite-dev = pkgs.sqlite.dev;
          };
          env = [
            { name = "ZEPHYR_SDK_INSTALL_DIR"; value = "${zephyr-sdk}"; }
            { name = "PYTHONPATH"; eval = "${python-packages}/lib/python3.9/site-packages:$PYTHONPATH"; }
            # NOTE: I'm using the PIP_TARGET below to work around the fact
            # that I can't install pyocd through nixpkgs at this time. Remove
            # this when I find a way to install pyocd through nixpkgs.
            { name = "PIP_TARGET"; value = local-pythonpkgs; }
            { name = "LD_LIBRARY_PATH"; eval = "${pkgs.libusb-compat-0_1}/lib:$LD_LIBRARY_PATH"; }
            { name = "ARMFVP_BIN_PATH"; value = pkgs.fvpCorestone; }
          ];
	};
    in
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = mkZephyrShell (import nixpkgs {
        inherit system;
        overlays = [
          devshell.overlay
          (import ./nix/overlay.nix)
        ];
      });
    });
}

