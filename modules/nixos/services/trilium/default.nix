{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.trilium;
  domain = inputs.nix-secrets.homelabDomain;
  port = 8082;
in
{
  options.services.flocke.trilium = {
    enable = mkEnableOption "Enable Trilium Notes server";
  };

  config = mkIf cfg.enable {
    sops.secrets.trilium-oauth-client-secret = { };

    services = {
      trilium-server = {
        enable = true;
        inherit port;
        instanceName = "naseschief";
        environmentFile = config.sops.secrets.trilium-oauth-client-secret.path;
      };

      caddy.virtualHosts."trilium.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
      };
    };

    systemd.services.trilium-server.environment = {
      TRILIUM_OAUTH_BASE_URL = "https://trilium.${domain}";
      TRILIUM_OAUTH_CLIENT_ID = "trilium";
      TRILIUM_OAUTH_ISSUER_BASE_URL = "https://auth.${domain}";
      TRILIUM_OAUTH_ISSUER_NAME = "Authelia";
    };
  };
}
