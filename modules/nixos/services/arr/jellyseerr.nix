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
      "d /persist/var/lib/arr/jellyseerr 0777 root root"
    ];

    containers.arr = {
      bindMounts = {
        "/var/lib/jellyseerr/" = {
          hostPath = "/persist/var/lib/arr/jellyseerr/";
          isReadOnly = false;
        };
      };
      config = {
        # issues with bind mount
        systemd.services.jellyseerr.serviceConfig.DynamicUser = lib.mkForce false;
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
              rule = "Host(`jellyseerr.homelab.${inputs.nix-secrets.domain}`)";
              service = "jellyseerr";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
