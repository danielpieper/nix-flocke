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

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/filebrowser/data";
      description = "Root directory for Filebrowser files";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra groups for the filebrowser user";
    };
  };

  config = mkIf cfg.enable {
    users.users.filebrowser.extraGroups = cfg.extraGroups;

    services = {
      filebrowser = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 8085;
          root = cfg.dataDir;
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
