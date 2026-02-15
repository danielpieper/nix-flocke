{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.gotify;
in
{
  options.services.flocke.gotify = {
    enable = mkEnableOption "Enable the notify service";
  };

  config = mkIf cfg.enable {
    services = {
      gotify = {
        enable = true;
        environment = {
          GOTIFY_SERVER_PORT = "8051";
        };
      };

      traefik = {
        dynamic.files."gotify".settings = {
          http = {
            services = {
              notify.loadBalancer.servers = [
                {
                  url = "http://localhost:8051";
                }
              ];
            };

            routers = {
              notify = {
                entryPoints = [ "websecure" ];
                rule = "Host(`notify.homelab.${inputs.nix-secrets.domain}`)";
                service = "notify";
              };
            };
          };
        };
      };
    };
  };
}
