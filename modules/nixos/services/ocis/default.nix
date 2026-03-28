{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.ocis;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.ocis = {
    enable = mkEnableOption "Enable ownCloud Infinite Scale";
  };

  config = mkIf cfg.enable {
    sops.secrets.ocis-config = {
      owner = "ocis";
      path = "/var/lib/ocis/config/ocis.yaml";
    };

    services = {
      ocis = {
        enable = true;
        configDir = "/var/lib/ocis/config";
        url = "https://ocis.${domain}";
        environment = {
          OCIS_INSECURE = "true";
          PROXY_HTTP_ADDR = "127.0.0.1:9200";
          PROXY_TLS = "false";
          # Use Authelia as external IDP, disable built-in IDP
          OCIS_EXCLUDE_RUN_SERVICES = "idp";
          PROXY_OIDC_ISSUER = "https://auth.${domain}";
          PROXY_OIDC_REWRITE_WELLKNOWN = "true";
          PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
          PROXY_OIDC_SKIP_USER_INFO = "false";
          WEB_OIDC_CLIENT_ID = "ocis";
          # Auto-provision users from OIDC claims
          PROXY_AUTOPROVISION_ACCOUNTS = "true";
          PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
          PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
          PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
          PROXY_AUTOPROVISION_CLAIM_GROUPS = "groups";
          PROXY_USER_OIDC_CLAIM = "preferred_username";
          PROXY_USER_CS3_CLAIM = "username";
        };
      };

      caddy.virtualHosts."ocis.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy localhost:9200";
      };
    };
  };
}
