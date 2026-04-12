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
        systemd.services.seerr = {
          after = [ "tailscaled.service" ];
          # issues with bind mount
          serviceConfig.DynamicUser = lib.mkForce false;
        };
        services = {
          seerr.enable = true;
          caddy.virtualHosts."jellyseerr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:5055
          '';
        };
      };
    };
  };
}
