{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.immich;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.immich = {
    enable = mkEnableOption "Enable Immich photo management";

    mediaLocation = mkOption {
      type = types.path;
      default = "/var/lib/immich";
      description = "Directory for Immich media storage";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra groups for the immich user";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.immich-oidc-client-secret.owner = "immich";

    users.users.immich.extraGroups = cfg.extraGroups;

    services = {
      immich = {
        enable = true;
        host = "127.0.0.1";
        port = 2283;
        inherit (cfg) mediaLocation;
        settings = {
          server.externalDomain = "https://immich.${domain}";
          newVersionCheck.enabled = false;
          oauth = {
            enabled = true;
            autoRegister = true;
            buttonText = "Login with Authelia";
            clientId = "immich";
            clientSecret._secret = config.sops.secrets.immich-oidc-client-secret.path;
            issuerUrl = "https://auth.${domain}/.well-known/openid-configuration";
          };
        };
      };

      caddy.virtualHosts."immich.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:2283";
      };
    };
  };
}
