{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/bazarr 0777 root root"
    ];

    containers.arr = {
      bindMounts = {
        "/var/lib/bazarr/" = {
          hostPath = "/persist/var/lib/arr/bazarr/";
          isReadOnly = false;
        };
      };
      config = {
        services = {
          bazarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.bazarr.loadBalancer.servers = [
              {
                url = "http://localhost:6767";
              }
            ];
            routers.bazarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`bazarr.homelab.${inputs.nix-secrets.domain}`)";
              service = "bazarr";
              tls.certResolver = "letsencrypt";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
