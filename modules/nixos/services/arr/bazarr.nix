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
      "d /persist/var/lib/arr/bazarr 0777 root root"
    ];

    containers.arr = {
      bindMounts = {
        "/var/lib/bazarr/" = {
          hostPath = "/persist/var/lib/arr/bazarr/";
          isReadOnly = false;
        };
      };
      config = {
        systemd.services.bazarr.after = [ "tailscaled.service" ];
        services = {
          bazarr = {
            enable = true;
            group = "media";
          };
          caddy.virtualHosts."bazarr.${inputs.nix-secrets.homelabDomain}".extraConfig = ''
            import arr-tls
            reverse_proxy localhost:6767
          '';
        };
      };
    };
  };
}
