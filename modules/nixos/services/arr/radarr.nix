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
        systemd.services.radarr.after = [ "tailscaled.service" ];
        services = {
          radarr = {
            enable = true;
            group = "media";
          };
          traefik.dynamic.files."radarr".settings.http = {
            services.radarr.loadBalancer.servers = [
              {
                url = "http://localhost:7878";
              }
            ];
            routers.radarr = {
              entryPoints = [ "websecure" ];
              rule = "Host(`radarr.homelab.${inputs.nix-secrets.domain}`)";
              service = "radarr";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
