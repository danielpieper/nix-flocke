{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.miniflux;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.miniflux = {
    enable = mkEnableOption "Enable the miniflux feed reader";
  };

  config = mkIf cfg.enable {
    sops.secrets.miniflux_env = { };

    services = {
      miniflux = {
        enable = true;
        createDatabaseLocally = true;
        adminCredentialsFile = config.sops.secrets.miniflux_env.path;
        config = {
          LISTEN_ADDR = "localhost:8910";
          BASE_URL = "https://miniflux.${domain}/";
          HTTPS = 1;
          OAUTH2_PROVIDER = "oidc";
          OAUTH2_CLIENT_ID = "miniflux";
          OAUTH2_REDIRECT_URL = "https://miniflux.${domain}/oauth2/oidc/callback";
          OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.${domain}";
          OAUTH2_USER_CREATION = 1;
        };
      };

      traefik.dynamicConfigOptions.http = {
        services.miniflux.loadBalancer.servers = [ { url = "http://localhost:8910"; } ];
        routers.miniflux = {
          entryPoints = [ "websecure" ];
          rule = "Host(`miniflux.homelab.${inputs.nix-secrets.domain}`)";
          service = "miniflux";
        };
      };

      caddy.virtualHosts."miniflux.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy localhost:8910";
      };
    };
  };
}
