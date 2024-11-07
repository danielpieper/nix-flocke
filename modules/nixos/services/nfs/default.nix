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
    # sops.secrets.nfs_smb_secrets = {
    #   sopsFile = ../secrets.yaml;
    # };

    environment.systemPackages = with pkgs; [
      cifs-utils
      nfs-utils
    ];

    fileSystems = {
      "/mnt/nas/11tb" = {
        device = "//192.168.178.38/11tb";
        fsType = "cifs";
        options = [
          "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
        ];
      };

      "/mnt/nas/5.5tb" = {
        device = "//192.168.178.38/5.5tb";
        fsType = "cifs";
        options = [
          "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
        ];
      };
    };
  };
}
