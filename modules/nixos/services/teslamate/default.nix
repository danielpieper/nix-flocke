{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.teslamate;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.teslamate = {
    enable = mkEnableOption "Enable The teslamate data logger";
    runMigrations = mkEnableOption "Run teslamate database migrations as a separate service";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      teslamate = {
        owner = config.users.users.teslamate.name;
        inherit (config.users.users.teslamate) group;
      };
      teslamate-db-password.owner = "grafana";
    };

    services = {
      teslamate = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 4000;
        virtualHost = "tesla.${domain}";
        secretsFile = config.sops.secrets.teslamate.path;

        postgres.enable_server = false;
        grafana.enable = false;
      };

      postgresql = {
        ensureDatabases = [ "teslamate" ];
        ensureUsers = [
          {
            name = "teslamate";
            ensureDBOwnership = true;
            ensureClauses.password = inputs.nix-secrets.teslamate.postgresPasswordHash;
          }
        ];
        # TeslaMate connects via TCP with password auth
        authentication = lib.mkAfter ''
          host teslamate teslamate 127.0.0.1/32 scram-sha-256
        '';
      };

      grafana.provision = {
        dashboards.settings.providers = [
          {
            name = "TeslaMate";
            orgId = 1;
            folder = "TeslaMate";
            folderUid = "teslamate";
            type = "file";
            disableDeletion = true;
            allowUiUpdates = false;
            updateIntervalSeconds = 86400;
            options.path = "${inputs.teslamate}/grafana/dashboards";
          }
        ];
        datasources.settings.datasources = [
          {
            name = "TeslaMate";
            type = "postgres";
            access = "proxy";
            url = "localhost:5432";
            user = "teslamate";
            editable = false;
            jsonData = {
              postgresVersion = 1700;
              sslmode = "disable";
              database = "teslamate";
            };
            secureJsonData = {
              password = "$__file{${config.sops.secrets.teslamate-db-password.path}}";
            };
          }
        ];
      };

      caddy.virtualHosts."tesla.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:4000";
      };
    };

    # Systemd service for running database migrations independently
    systemd.services.teslamate-migrate = mkIf cfg.runMigrations {
      description = "TeslaMate Database Migrations";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
      ];
      requires = [ "postgresql.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = config.users.users.teslamate.name;
        Group = config.users.users.teslamate.group;
        RemainAfterExit = true;
        EnvironmentFile = config.sops.secrets.teslamate.path;
      };

      environment =
        let
          teslaCfg = config.services.teslamate;
        in
        {
          DATABASE_USER = teslaCfg.postgres.user;
          DATABASE_NAME = teslaCfg.postgres.database;
          DATABASE_HOST = teslaCfg.postgres.host;
          DATABASE_PORT = toString teslaCfg.postgres.port;
          MQTT_HOST = "";
        };

      script = ''
        ${
          lib.getExe inputs.teslamate.packages.${pkgs.stdenv.hostPlatform.system}.default
        } eval "TeslaMate.Release.migrate"
      '';
    };

    # Make teslamate service wait for migrations when both are enabled
    systemd.services.teslamate = mkIf cfg.runMigrations {
      after = [ "teslamate-migrate.service" ];
      requires = [ "teslamate-migrate.service" ];
    };
  };
}
