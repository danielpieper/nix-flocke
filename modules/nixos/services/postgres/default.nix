{
  config,
  lib,
  pkgs,
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
        # TODO: look at using default postgres
        package = pkgs.postgresql_16_jit;
        extraPlugins = ps: with ps; [ pgvecto-rs ];
        settings = {
          shared_preload_libraries = [ "vectors.so" ];
          search_path = "\"$user\", public, vectors";
        };
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
