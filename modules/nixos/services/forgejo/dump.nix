{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.forgejo;
in
{
  options.services.flocke.forgejo = {
    enable-dump = mkEnableOption "Enable Forgejo daily dump";
  };

  config = mkIf cfg.enable-dump {
    services = {
      forgejo.dump = {
        enable = true;
        backupDir = "/mnt/nas/11tb/forgejo";
        file = "forgejo-dump";
      };
      flocke.nfs.enable = true;
    };
    systemd.services.forgejo.unitConfig = {
      RequiresMountsFor = "/mnt/nas/11tb";
    };
  };
}
