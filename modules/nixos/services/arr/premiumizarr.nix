{
  config,
  lib,
  pkgs,
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
      "d /persist/var/lib/arr/premiumizarr 0777 root root"
      "d /persist/var/lib/arr/premiumizarr/blackhole 0777 root root"
      "d /persist/var/lib/arr/premiumizarr/downloads 0777 root root"
      "d /persist/var/lib/arr/premiumizarr/unzip 0777 root root"
    ];
    containers.arr = {
      bindMounts = {
        "/var/lib/premiumizarr/" = {
          hostPath = "/persist/var/lib/arr/premiumizarr/";
          isReadOnly = false;
        };
      };
      config = {
        sops.secrets.premiumizarr-config = {
          path = "/var/lib/premiumizarr/config.yaml";
          owner = "premiumizarr";
        };

        systemd.services.premiumizearrd = {
          description = "DownloadManger for *Arr clients";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          environment = {
            PREMIUMIZEARR_LOG_LEVEL = "trace";
            PREMIUMIZEARR_CONFIG_DIR_PATH = "/var/lib/premiumizarr";
            PREMIUMIZEARR_LOGGING_DIR_PATH = "/var/lib/premiumizarr";
          };
          path = [ pkgs.wget ];
          serviceConfig = {
            ExecStart = "${pkgs.flocke.premiumizarr-nova}/bin/premiumizearrd";
            WorkingDirectory = "${pkgs.flocke.premiumizarr-nova}";
            Restart = "always";
            User = "premiumizarr";
            Group = "media";
            UMask = "0002";
          };
        };

        users.users.premiumizarr = {
          group = "media";
          home = "/var/lib/premiumizarr";
          isSystemUser = true;
        };

        services.traefik.dynamicConfigOptions.http = {
          services.premiumizarr.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8182";
            }
          ];
          routers.premiumizarr = {
            entryPoints = [ "websecure" ];
            rule = "Host(`premiumizarr.homelab.${inputs.nix-secrets.domain}`)";
            service = "premiumizarr";
            tls.certResolver = "letsencrypt";
            middlewares = [ "authentik" ];
          };
        };
      };
    };
  };
}
