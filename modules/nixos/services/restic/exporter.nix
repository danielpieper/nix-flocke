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
    enable_exporter = mkEnableOption "Enable the restic prometheus exporter (uses SFTP repository)";
  };

  config = mkIf (cfg.enable && cfg.enable_exporter) {
    users.users.restic-exporter = {
      isSystemUser = true;
      group = "restic-exporter";
    };
    users.groups.restic-exporter = { };

    sops.secrets = {
      restic_repository_password = {
        group = "restic-exporter";
        mode = "0440";
      };
      restic_repository = {
        group = "restic-exporter";
        mode = "0440";
      };
      restic_environment = {
        group = "restic-exporter";
        mode = "0440";
      };
    };

    systemd.tmpfiles.rules = [
      "z /persist/etc/ssh/restic-exporter_ed25519 0600 restic-exporter restic-exporter -"
    ];

    services.prometheus = {
      exporters.restic = {
        enable = true;
        user = "restic-exporter";
        group = "restic-exporter";
        repositoryFile = config.sops.secrets.restic_repository.path;
        passwordFile = config.sops.secrets.restic_repository_password.path;
        environmentFile = config.sops.secrets.restic_environment.path;
        listenAddress = "127.0.0.1";
        port = 9753;
        refreshInterval = 10800;
      };
      scrapeConfigs = [
        {
          job_name = "restic-exporter";
          static_configs = [ { targets = [ "127.0.0.1:9753" ]; } ];
        }
      ];
    };

    systemd.services.prometheus-restic-exporter.serviceConfig = {
      DynamicUser = mkForce false;
    };
  };
}
