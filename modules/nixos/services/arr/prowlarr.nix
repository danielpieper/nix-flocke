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
      "d /persist/var/lib/arr/prowlarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/prowlarr/" = {
          hostPath = "/persist/var/lib/arr/prowlarr/";
          isReadOnly = false;
        };
      };
      config = {
        # issues with bind mount
        systemd.services.prowlarr.serviceConfig.DynamicUser = lib.mkForce false;
        services = {
          prowlarr.enable = true;
          traefik.dynamicConfigOptions.http = {
            services.prowlarr.loadBalancer.servers = [
              {
                url = "http://localhost:9696";
              }
            ];
            routers.prowlarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`prowlarr.homelab.${inputs.nix-secrets.domain}`)";
              service = "prowlarr";
              tls.certResolver = "letsencrypt";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
