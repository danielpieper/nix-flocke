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
      "d /persist/var/lib/arr/sabnzbd 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/sabnzbd/" = {
          hostPath = "/persist/var/lib/arr/sabnzbd/";
          isReadOnly = false;
        };
      };
      config = {
        systemd.services.sabnzbd.after = [ "tailscaled.service" ];
        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "unrar"
          ];
        services = {
          sabnzbd = {
            enable = true;
            group = "media";
            configFile = "/var/lib/sabnzbd/config.ini";
          };
          traefik.dynamic.files."sabnzbd".settings.http = {
            services.sabnzbd.loadBalancer.servers = [
              {
                url = "http://localhost:8090";
              }
            ];
            routers.sabnzbd = {
              entryPoints = [ "websecure" ];
              rule = "Host(`sabnzbd.homelab.${inputs.nix-secrets.domain}`)";
              service = "sabnzbd";
              middlewares = [ "authentik" ];
            };
          };
        };
        systemd.services.sabnzbd.serviceConfig.UMask = "0002";
      };
    };
  };
}
