{
  description = "Aurora linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    omarchy-pkgs = {
      url = "github:omacom/omarchy-pkgs";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          packages.m1n1 = pkgs.callPackage ./packages/m1n1.nix { };
          packages.aurora-kernel = (pkgs.callPackage ./packages/kernel.nix { }).kernel;
          packages.aurora-libfprint = pkgs.callPackage ./packages/libfprint.nix {
            omarchy = inputs.omarchy-pkgs;
          };
        };

      flake = {
        nixosModules = {
          sep = import ./modules/modprobe-sep.nix;
          kernel = import ./modules/kernel.nix self;
          fprintd = import ./modules/fprintd.nix self;
          default = {
            imports = [
              self.nixosModules.sep
              self.nixosModules.kernel
              self.nixosModules.fprintd
            ];
          };
        };

        overlays.default = final: prev: {
          m1n1 = final.callPackage ./packages/m1n1.nix { };
          aurora-kernel = (final.callPackage ./packages/kernel.nix { }).kernel;
          aurora-libfprint = final.callPackage ./packages/libfprint.nix {
            omarchy = inputs.omarchy-pkgs;
          };
        };
      };
    };
}
