{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.storagebox;
  sb = inputs.nix-secrets.storageBox.data;
in
{
  options.services.flocke.storagebox = {
    enable = mkEnableOption "Enable Hetzner Storage Box CIFS mount";

    mountPoint = mkOption {
      type = types.path;
      default = "/mnt/storagebox";
      description = "Mount point for the Storage Box";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.storagebox-data-credentials = { };

    users.groups.storagebox = { };

    environment.systemPackages = [ pkgs.cifs-utils ];

    fileSystems.${cfg.mountPoint} = {
      device = "//${sb.host}/${sb.username}";
      fsType = "cifs";
      options = [
        "credentials=${config.sops.secrets.storagebox-data-credentials.path}"
        "gid=${toString config.users.groups.storagebox.gid}"
        "file_mode=0660"
        "dir_mode=0770"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
      ];
    };
  };
}
