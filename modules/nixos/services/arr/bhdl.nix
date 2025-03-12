{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/bhdl 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/bhdl/" = {
          hostPath = "/persist/var/lib/arr/bhdl/";
          isReadOnly = false;
        };
      };
      config = {
        sops.secrets.bhdl-config = {
          sopsFile = ../secrets.yaml;
          path = "/var/lib/bhdl/config.yaml";
        };
        services = {
          bhdl = {
            enable = true;
            package = inputs.bhdl.packages.x86_64-linux.default;
            group = "media";
          };
          traefik.dynamicConfigOptions.http = {
            services.bhdl.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:8182";
              }
            ];
            routers.bhdl = {
              entryPoints = [ "websecure" ];
              rule = "Host(`bhdl.homelab.daniel-pieper.com`)";
              service = "bhdl";
              tls.certResolver = "letsencrypt";
              # middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
