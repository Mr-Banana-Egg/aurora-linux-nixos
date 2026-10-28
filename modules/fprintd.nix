self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.aurora.fprintd;
in
{
  options.hardware.aurora.fprintd = {
    enable = lib.mkEnableOption "Fprintd patches to get fprintd working.";
  };

  config = lib.mkIf cfg.enable {
          services.fprintd = {
        enable = true;
        package = pkgs.fprintd.override { libfprint = self.packages.${pkgs.stdenv.hostPlatform.system}.aurora-libfprint; };
      };
      systemd.services.fprintd.serviceConfig.DeviceAllow = [
        "/dev/sep-bio rw"
        "char-input r"
      ];
  };
}
