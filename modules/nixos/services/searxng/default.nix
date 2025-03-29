{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.searxng;
in
{
  options.services.flocke.searxng = {
    enable = mkEnableOption "Enable The searxng search engine";
  };

  config = mkIf cfg.enable {
    services.searx = {
      enable = true;
      environmentFile = config.sops.secrets.searx.path;
      settings = {
        server = {
          port = 8088;
          bind_address = "localhost";
          secret_key = "@SEARX_SECRET_KEY@";
        };
        search = {
          autocomplete = "google";
        };
        ui = {
          hotkeys = "vim";
        };
      };
    };

    sops.secrets.searx = {
      owner = config.users.users.searx.name;
      group = config.users.users.searx.group;
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services = {
            searxng.loadBalancer.servers = [
              {
                url = "http://localhost:8088";
              }
            ];
          };

          routers = {
            searxng = {
              entryPoints = [ "websecure" ];
              rule = "Host(`search.homelab.${inputs.nix-secrets.domain}`)";
              service = "searxng";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
