self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.aurora.fingerprint;
in
{
  options.hardware.aurora.fingerprint.enable =
    lib.mkEnableOption "fingerprint support (SEP, fprintd, m1n1). Requires hardware.aurora.kernel.enable";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hardware.aurora.kernel.enable;
        message = "hardware.aurora.fingerprint.enable requires hardware.aurora.kernel.enable = true.";
      }
    ];

    hardware.aurora.sep.enable = true;
    hardware.aurora.fprintd.enable = true;

    boot.m1n1Package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.m1n1;
  };
}
