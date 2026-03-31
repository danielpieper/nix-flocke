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
      "d /persist/var/lib/arr/lidarr 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/lidarr/" = {
          hostPath = "/persist/var/lib/arr/lidarr/";
          isReadOnly = false;
        };
      };
      config = {
        systemd.services.lidarr.after = [ "tailscaled.service" ];
        services = {
          lidarr = {
            enable = true;
            group = "media";
          };
          caddy.virtualHosts."lidarr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:8686
          '';
        };
      };
    };
  };
}
