{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/radarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/radarr/" = {
          hostPath = "/persist/var/lib/arr/radarr/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          radarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.radarr.loadBalancer.servers = [
              {
                url = "http://localhost:7878";
              }
            ];
            routers.radarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`radarr.homelab.daniel-pieper.com`)";
              service = "radarr";
              tls.certResolver = "letsencrypt";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
