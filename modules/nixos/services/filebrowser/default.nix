{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.filebrowser;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.filebrowser = {
    enable = mkEnableOption "Enable Filebrowser";
  };

  config = mkIf cfg.enable {
    services = {
      filebrowser = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 8085;
          root = "/var/lib/filebrowser/data";
          auth = {
            method = "proxy";
            header = "Remote-User";
          };
        };
      };

      caddy.virtualHosts."filebrowser.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
          reverse_proxy 127.0.0.1:8085
        '';
      };
    };
  };
}
