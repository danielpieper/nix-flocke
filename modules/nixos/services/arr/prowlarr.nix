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
        systemd.services.prowlarr = {
          after = [ "tailscaled.service" ];
          # issues with bind mount
          serviceConfig.DynamicUser = lib.mkForce false;
        };
        services = {
          prowlarr.enable = true;
          caddy.virtualHosts."prowlarr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:9696
          '';
        };
      };
    };
  };
}
