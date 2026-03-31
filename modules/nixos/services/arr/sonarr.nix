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
      "d /persist/var/lib/arr/sonarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/sonarr/" = {
          hostPath = "/persist/var/lib/arr/sonarr/";
          isReadOnly = false;
        };
      };
      config = {
        systemd.services.sonarr.after = [ "tailscaled.service" ];
        services = {
          sonarr = {
            enable = true;
            group = "media";
          };
          caddy.virtualHosts."sonarr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:8989
          '';
        };
      };
    };
  };
}
