{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.actual;
in
{
  options.services.flocke.actual = {
    enable = mkEnableOption "Enable actual budget";
  };

  config = mkIf cfg.enable {
    services.actual = {
      enable = true;
      settings = {
        hostname = "localhost";
        port = 5006;
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services = {
            actual.loadBalancer.servers = [
              {
                url = "http://localhost:5006";
              }
            ];
          };

          routers = {
            actual = {
              entryPoints = [ "websecure" ];
              rule = "Host(`actual.homelab.daniel-pieper.com`)";
              service = "actual";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
