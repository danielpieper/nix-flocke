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
          caddy.virtualHosts."radarr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:7878
          '';
        };
      };
    };
  };
}
