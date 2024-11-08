{
  config,
  lib,
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
    # TODO: use postgresql module for teslamate
    # services.flocke.postgresql.enable = true;

    services.teslamate = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 4000;
      virtualHost = "tesla.homelab.daniel-pieper.com";

      secretsFile = config.sops.secrets.teslamate.path;

      postgres.enable_server = true;
      grafana.enable = true;
      # mqtt.enable = true;
    };

    sops.secrets.teslamate = {
      sopsFile = ../secrets.yaml;
      owner = config.users.users.teslamate.name;
      group = config.users.users.teslamate.group;
    };

    services.traefik = {
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
                url = "http://localhost:3000";
              }
            ];
          };

          routers = {
            teslamate = {
              entryPoints = [ "websecure" ];
              rule = "Host(`tesla.homelab.daniel-pieper.com`)";
              service = "teslamate";
              tls.certResolver = "letsencrypt";
            };
            grafana = {
              entryPoints = [ "websecure" ];
              rule = "Host(`grafana.homelab.daniel-pieper.com`)";
              service = "grafana";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
