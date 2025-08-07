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
      "d /persist/var/lib/arr/headphones 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/headphones/" = {
          hostPath = "/persist/var/lib/arr/headphones/";
          isReadOnly = false;
        };
      };
      config = {
        systemd.services.headphones.after = [ "tailscaled.service" ];
        services = {
          headphones = {
            enable = true;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.headphones.loadBalancer.servers = [
              {
                url = "http://localhost:8181";
              }
            ];
            routers.headphones = {
              entryPoints = [ "websecure" ];
              rule = "Host(`headphones.homelab.${inputs.nix-secrets.domain}`)";
              service = "headphones";
              # TODO: add authentik middleware
            };
          };
        };
      };
    };
  };
}
