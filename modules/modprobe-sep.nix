{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.aurora.sep;
in
{
  options.hardware.aurora.sep = {
    enable = lib.mkEnableOption "Apple SEP and Touch ID support (loads the apple-sep module at boot)";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.apple-sep = {
      description = "Apple SEP and Touch ID";
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "/dev/disk/by-partlabel/iBootSystemContainer";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.kmod}/bin/modprobe apple-sep";
      };
    };
  };
}
