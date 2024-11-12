{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;
in
{
  options.services.flocke.restic = {
    enable = mkEnableOption "Enable the restic backup client";
  };

  config = mkIf cfg.enable {
    services.restic.backups = {
      default = {
        repository = "rest:https://restic.homelab.daniel-pieper.com";
        initialize = true;
        passwordFile = config.sops.secrets.restic_repository_password.path;
        environmentFile = config.sops.secrets.restic_environment.path;
        paths = [
          "/persist"
        ];
        extraBackupArgs = [
          "--exclude-caches"
          "--exclude=steamapps"
          "--exclude=valheim_server_data"
          "--exclude=satisfactory/FactoryGame"
          "--exclude=satisfactory/Engine"
          "--exclude=var/lib/docker"
          "--exclude=games"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
        timerConfig = {
          OnCalendar = "00:05";
          RandomizedDelaySec = "5h";
        };
      };
    };

    sops.secrets = {
      restic_repository_password = {
        sopsFile = ../secrets.yaml;
      };
      restic_environment = {
        sopsFile = ../secrets.yaml;
      };
    };

  };
}
