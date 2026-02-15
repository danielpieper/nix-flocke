{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.miniflux;
in
{
  options.services.flocke.miniflux = {
    enable = mkEnableOption "Enable the miniflux feed reader";
  };

  config = mkIf cfg.enable {
    sops.secrets.miniflux_env = { };

    services = {
      miniflux = {
        enable = true;
        createDatabaseLocally = true;
        adminCredentialsFile = config.sops.secrets.miniflux_env.path;
        config = {
          # https://miniflux.app/docs/configuration.html
          LISTEN_ADDR = "localhost:8910";
          BASE_URL = "https://miniflux.homelab.${inputs.nix-secrets.domain}/";
          HTTPS = 1;
          # LOG_LEVEL = "debug";
        };
      };
      traefik = {
        dynamic.files."miniflux".settings = {
          http = {
            services = {
              miniflux.loadBalancer.servers = [
                {
                  url = "http://localhost:8910";
                }
              ];
            };

            routers = {
              miniflux = {
                entryPoints = [ "websecure" ];
                rule = "Host(`miniflux.homelab.${inputs.nix-secrets.domain}`)";
                service = "miniflux";
              };
            };
          };
        };
      };
    };
  };
}
