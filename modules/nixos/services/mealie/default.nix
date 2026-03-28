{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.mealie;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.mealie = {
    enable = mkEnableOption "Enable Mealie recipe manager";
  };

  config = mkIf cfg.enable {
    sops.secrets.mealie_env = { };

    services = {
      mealie = {
        enable = true;
        port = 9925;
        database.createLocally = true;
        credentialsFile = config.sops.secrets.mealie_env.path;
        settings = {
          BASE_URL = "https://mealie.${domain}";
          OIDC_AUTH_ENABLED = "true";
          OIDC_SIGNUP_ENABLED = "true";
          OIDC_CONFIGURATION_URL = "https://auth.${domain}/.well-known/openid-configuration";
          OIDC_CLIENT_ID = "mealie";
          OIDC_AUTO_REDIRECT = "false";
          OIDC_PROVIDER_NAME = "Authelia";
          OIDC_ADMIN_GROUP = "admin";
          OIDC_USER_GROUP = "users";
        };
      };

      caddy.virtualHosts."mealie.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy localhost:9925";
      };
    };
  };
}
