{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.postgresql;
in
{
  options.services.flocke.postgresql = {
    enable = mkEnableOption "Enable postgresql";
  };

  config = mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;
      };
      postgresqlBackup = {
        # TODO: postgres backup
        enable = false;
        location = "/mnt/share/postgresql";
        backupAll = true;
        startAt = "*-*-* 10:00:00";
      };
    };
  };
}
