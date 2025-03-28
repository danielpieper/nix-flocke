{ config
, lib
, inputs
, ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/sonarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/sonarr/" = {
          hostPath = "/persist/var/lib/arr/sonarr/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          sonarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.sonarr.loadBalancer.servers = [
              {
                url = "http://localhost:8989";
              }
            ];
            routers.sonarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`sonarr.homelab.${inputs.nix-secrets.domain}`)";
              service = "sonarr";
              tls.certResolver = "letsencrypt";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
