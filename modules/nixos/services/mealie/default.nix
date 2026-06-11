{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.mealie;
  domain = inputs.nix-secrets.homelabDomain;
  bringPort = 8742;
in
{
  options.services.flocke.mealie = {
    enable = mkEnableOption "Enable Mealie recipe manager";

    bring = {
      enable = mkEnableOption "Bridge Mealie shopping lists to Bring";
    };
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

    # mealie-bring-api: small Flask service Mealie POSTs recipe ingredients to
    # via a recipe action. Listens on localhost only — Mealie reaches it
    # in-host, so it is never exposed through Caddy. Configure the recipe
    # action in Mealie's UI to POST to http://127.0.0.1:8742/.
    sops.secrets.mealie_bring_env = mkIf cfg.bring.enable { };

    systemd.services.mealie-bring-api = mkIf cfg.bring.enable {
      description = "Mealie to Bring shopping list bridge";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "mealie.service"
      ];
      environment = {
        HTTP_HOST = "127.0.0.1";
        HTTP_PORT = toString bringPort;
        MEALIE_BASE_URL = "https://mealie.${domain}";
      };
      serviceConfig = {
        ExecStart = getExe pkgs.flocke.mealie-bring-api;
        # BRING_USERNAME / BRING_PASSWORD / BRING_LIST_NAME (and optional
        # MEALIE_API_KEY) live in this sops EnvironmentFile.
        EnvironmentFile = config.sops.secrets.mealie_bring_env.path;
        Restart = "on-failure";
        RestartSec = 10;

        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
