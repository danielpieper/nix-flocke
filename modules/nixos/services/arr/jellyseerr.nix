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
      "d /persist/var/lib/arr/jellyseer 0777 root root"
    ];

    containers.arr = {
      bindMounts = {
        "/var/lib/jellyseer/" = {
          hostPath = "/persist/var/lib/arr/jellyseer/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          jellyseerr.enable = true;
          traefik.dynamicConfigOptions.http = {
            services.jellyseerr.loadBalancer.servers = [
              {
                url = "http://localhost:5055";
              }
            ];
            routers.jellyseerr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`jellyseerr.homelab.daniel-pieper.com`)";
              service = "jellyseerr";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
