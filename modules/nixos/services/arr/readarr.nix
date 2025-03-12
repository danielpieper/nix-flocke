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
      "d /persist/var/lib/arr/readarr 0777 root root"
    ];

    containers.arr = {
      bindMounts = {
        "/var/lib/readarr/" = {
          hostPath = "/persist/var/lib/arr/readarr/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          readarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.readarr.loadBalancer.servers = [
              {
                url = "http://localhost:8787";
              }
            ];
            routers.readarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`readarr.homelab.daniel-pieper.com`)";
              service = "readarr";
              tls.certResolver = "letsencrypt";
              # middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
