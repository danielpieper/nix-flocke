{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.nfs;
in
{
  options.services.flocke.nfs = {
    enable = mkEnableOption "Enable the (mount) nfs drive";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cifs-utils
      nfs-utils
    ];

    fileSystems = {
      "/mnt/nas/11tb" = {
        device = "//192.168.178.38/11tb";
        fsType = "cifs";
        options = [
          "guest"
          "rw"
          "noperm"
          "file_mode=0777"
          "dir_mode=0777"
          "nounix"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=60"
          "x-systemd.mount-timeout=5s"
        ];
      };
    };
  };
}
