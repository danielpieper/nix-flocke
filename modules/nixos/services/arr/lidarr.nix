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
      "d /persist/var/lib/arr/lidarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/lidarr/" = {
          hostPath = "/persist/var/lib/arr/lidarr/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          lidarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.lidarr.loadBalancer.servers = [
              {
                url = "http://localhost:8686";
              }
            ];
            routers.lidarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`lidarr.homelab.daniel-pieper.com`)";
              service = "lidarr";
              tls.certResolver = "letsencrypt";
              # middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
