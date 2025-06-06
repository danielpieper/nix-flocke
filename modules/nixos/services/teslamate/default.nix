{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.teslamate;
in
{
  options.services.flocke.teslamate = {
    enable = mkEnableOption "Enable The teslamate data logger";
  };

  config = mkIf cfg.enable {

    sops.secrets.teslamate = {
      owner = config.users.users.teslamate.name;
      inherit (config.users.users.teslamate) group;
    };

    services = {
      teslamate = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 4000;
        virtualHost = "tesla.homelab.${inputs.nix-secrets.domain}";
        secretsFile = config.sops.secrets.teslamate.path;

        postgres.enable_server = true;
        grafana = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = 3010;
        };
        # mqtt.enable = true;
      };

      # the postgres and grafana settings in this module https://github.com/teslamate-org/teslamate/blob/master/nix/module.nix
      # interfere with the monitoring service.
      grafana = {
        settings = {
          dashboards.default_home_dashboard_path = lib.mkForce null;
          server.root_url = lib.mkForce "https://grafana.homelab.${inputs.nix-secrets.domain}";
          # uncomment for first time setup
          # users.allow_sign_up = lib.mkForce true;
        };
        provision.datasources = {
          path = lib.mkForce null;
          settings.datasources = [
            {
              name = "TeslaMate";
              type = "postgres";
              access = "proxy";
              url = "$DATABASE_HOST:$DATABASE_PORT";
              user = "$DATABASE_USER";
              editable = false;
              secureJsonData = {
                password = "$DATABASE_PASS";
              };
              jsonData = {
                postgresVersion = 1500;
                sslmode = "$DATABASE_SSL_MODE";
                database = "$DATABASE_NAME";
              };
            }
          ];
        };
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              teslamate.loadBalancer.servers = [
                {
                  url = "http://localhost:4000";
                }
              ];
              grafana.loadBalancer.servers = [
                {
                  url = "http://localhost:3010";
                }
              ];
            };

            routers = {
              teslamate = {
                entryPoints = [ "websecure" ];
                rule = "Host(`tesla.homelab.${inputs.nix-secrets.domain}`)";
                service = "teslamate";
              };
              grafana = {
                entryPoints = [ "websecure" ];
                rule = "Host(`grafana.homelab.${inputs.nix-secrets.domain}`)";
                service = "grafana";
              };
            };
          };
        };
      };
    };
  };
}
