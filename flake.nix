{
  description = "Aurora linux";

  nixConfig = {
    extra-substituters = [ "https://aurora-linux-nixos.cachix.org" ];
    extra-trusted-public-keys = [
      "aurora-linux-nixos.cachix.org-1:GLmR9BtSA8OY7UZMUCG9eMaWZEvXJCR4b/pYH4dhX+E="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aurora-kernel = {
      url = "github:omacom/linux-aurora/aurora-2026.10.17.20";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omarchy-pkgs = {
      url = "github:omacom/omarchy-pkgs";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      auroraPackages = pkgs: {
        m1n1 = pkgs.callPackage ./packages/m1n1.nix { };
        userpages = pkgs.callPackage ./packages/userpages.nix {
          aurora-kernel = inputs.aurora-kernel;
        };
        aurora-kernel =
          (pkgs.callPackage ./packages/kernel.nix {
            aurora-kernel = inputs.aurora-kernel;
          }).kernel;
        aurora-libfprint = pkgs.callPackage ./packages/libfprint.nix {
          omarchy-pkgs = inputs.omarchy-pkgs;
        };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
          pkgSet = auroraPackages pkgs;
        in
        {
          formatter = treefmtEval.config.build.wrapper;
          checks.formatting = treefmtEval.config.build.check self;

          packages = pkgSet // {
            all = pkgs.linkFarm "aurora-all" pkgSet;
          };
        };

      flake = {
        nixosModules = {
          sep = import ./modules/modprobe-sep.nix;
          kernel = import ./modules/kernel.nix self;
          fprintd = import ./modules/fprintd.nix self;
          fingerprint = import ./modules/fingerprint.nix self;

          cache =
            { config, lib, ... }:
            let
              cfg = config.hardware.aurora.binaryCache;
            in
            {
              options.hardware.aurora.binaryCache.enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Use the aurora-linux-nixos Cachix binary cache.";
              };

              config = lib.mkIf cfg.enable {
                nix.settings = {
                  substituters = [ "https://aurora-linux-nixos.cachix.org" ];
                  trusted-public-keys = [
                    "aurora-linux-nixos.cachix.org-1:GLmR9BtSA8OY7UZMUCG9eMaWZEvXJCR4b/pYH4dhX+E="
                  ];
                };
              };
            };

          default = {
            imports = [
              self.nixosModules.sep
              self.nixosModules.kernel
              self.nixosModules.fprintd
              self.nixosModules.fingerprint
              self.nixosModules.cache
            ];
          };
        };

        # Exact drvs CI built (aurora's own nixpkgs), so hashes match the
        # cache regardless of the host's nixpkgs.
        overlays.default =
          final: prev: builtins.removeAttrs self.packages.${final.stdenv.hostPlatform.system} [ "all" ];
      };
    };
}
