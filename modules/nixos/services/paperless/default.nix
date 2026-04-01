{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.paperless;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.paperless = {
    enable = mkEnableOption "Enable Paperless-ngx document management";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/paperless";
      description = "Directory for Paperless data storage";
    };

  };

  config = mkIf cfg.enable {
    sops.secrets = {
      paperless-password.owner = "paperless";
      paperless-env.owner = "paperless";
    };

    services = {
      paperless = {
        enable = true;
        address = "127.0.0.1";
        port = 28981;
        inherit (cfg) dataDir;
        passwordFile = config.sops.secrets.paperless-password.path;
        environmentFile = config.sops.secrets.paperless-env.path;
        settings = {
          PAPERLESS_URL = "https://paperless.${domain}";
          PAPERLESS_DBHOST = "/run/postgresql";
          PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        };
      };

      postgresql = {
        ensureDatabases = [ "paperless" ];
        ensureUsers = [
          {
            name = "paperless";
            ensureDBOwnership = true;
          }
        ];
      };

      caddy.virtualHosts."paperless.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:28981";
      };
    };
  };
}
